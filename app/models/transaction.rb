class Transaction < ApplicationRecord
  has_many :entries, :dependent => :destroy, inverse_of: :transaction_new
  belongs_to :updater, :class_name => 'User', :foreign_key => :updated_by, optional: true
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, optional: true
  accepts_nested_attributes_for :entries, :allow_destroy => true, :reject_if => :all_blank
  belongs_to :entity
  before_validation :remove_blank_entries!
  before_save :balanced?
  before_save :not_in_archived_period?
  before_destroy :not_in_archived_period?
  validates :entity_id, :description, :date, :created_by, :updated_by, presence: true


  def balanced?
    total = 0
    entries.each { |e| total += e.account.addition_or_subtraction * e.amount unless e.account.name == 'Retained earnings' }
    if total == 0
      return true
    else
      errors[:base] << "Does not balance"
      return false
    end

  end

  def archived?
    false
    # ArchiveDate.find(:first, :conditions => ["entity_id = ? AND start_date <= ? AND end_date >= ?",
    #     entity_id, date, date]).nil? ? false : true
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

  def not_in_archived_period?
    if archived?
      errors[:base] << "Transactions can't be created/updated/destroyed for this date as its during an archived period."
      return false
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
