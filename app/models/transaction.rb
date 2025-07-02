class Transaction < ApplicationRecord
  has_many :entries, :dependent => :destroy, inverse_of: :transaction_new
  belongs_to :updater, :class_name => 'User', :foreign_key => :updated_by, optional: true
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, optional: true
  accepts_nested_attributes_for :entries, :allow_destroy => true, :reject_if => :all_blank
  belongs_to :entity
  before_validation :remove_blank_entries!
  validate :must_be_balanced
  validate :check_not_in_archived_period
  before_destroy :check_destroy_not_in_archived_period
  validates :entity_id, :description, :date, presence: true

  def balanced?
    if total_balance == 0
      return true
    else
      return false
    end
  end

  def total_balance
    total = 0
    entries.each { |e| total += e.account.addition_or_subtraction * e.amount unless e.account.type == 'EquityAccount' }
    return total
  end

  def primary_entry_amount
    # First priority: expense or income accounts
    expense_income_entries = entries.joins(:account).where(accounts: { type: ['ExpenseAccount', 'IncomeAccount'] }).order(:id)
    return expense_income_entries.first.amount if expense_income_entries.any?
    
    # Second priority: liability or asset accounts
    liability_asset_entries = entries.joins(:account).where(accounts: { type: ['LiabilityAccount', 'AssetAccount'] }).order(:id)
    return liability_asset_entries.first.amount if liability_asset_entries.any?
    
    # Fallback: return the first entry amount
    entries.first&.amount || 0
  end

  def archived?
    (ArchiveDate.where("entity_id= ? AND start_date <= ? AND end_date >= ?",
        entity_id, date, date).any? ? true : false) || 
    (date_changed? && ArchiveDate.where("entity_id= ? AND start_date <= ? AND end_date >= ?",
        entity_id, date_was, date_was).any? ? true : false)
  end

  # Temporary method (Trash at some point) to fix equity postings
  def self.reprocess
    transactions = Transaction.find(:all, :order => 'date ASC, id ASC')
    transactions.each do |t|
      entries = t.entries.clone
      entries.each do |e|
        if e.account.class == IncomeAccount || e.account.class == ExpenseAccount
          new_entry = Entry.new(:transaction_id => t.id)
          new_entry.amount = - e.account.addition_or_subtraction * e.amount
          new_entry.account_id = Account.find_by_name_and_entity_id("Retained earnings", 1).id
          new_entry.related_entry_id = e.id
          new_entry.entry_type = "Closing"
          new_entry.save
        end
      end
    end
  end

  private

  def must_be_balanced
    if !balanced?
      errors.add(:base, "Transaction is not balanced.")
    end
  end

  def check_not_in_archived_period
    if archived?
      errors.add(:date, "is within an archived period.")
      return false
    end
  end

  def check_destroy_not_in_archived_period
    if archived?
      errors.add(:date, "is within an archived period.")
      throw :abort
    end
  end

  def remove_blank_entries!
    self.entries = entries - entries.select{|e| e.blank? }
    true
  end

  def self.find_transactions(search)
    transactions = []
    search.elements.each do |e|
      transactions += Transaction.
        where(:entity_id => search.entity_id).
        where("LOWER(description) LIKE LOWER('%#{e.element}%')").
        order('date DESC')
    end
    return transactions.uniq
  end


end
