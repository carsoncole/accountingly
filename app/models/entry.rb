class Entry < ActiveRecord::Base
  belongs_to :transaction_new, foreign_key: 'transaction_id', class_name: 'Transaction', counter_cache: true # done this way to avoid transaction name warning
  belongs_to :account
  has_one :entity, :through => :account
  validates_numericality_of :amount
  validates :account_id, :presence => true

  before_save :update_balances
  before_validation :check_if_archived
  after_save :clone_income_and_expense_to_equity
  after_destroy :update_balances

  # has_attached_file :attachment,
  #   :styles => {
  #     :large => ["900x900>", :png],
  #     :medium => ["500x600>", :png],
  #     :thumb => ["90x90>", :png]
  #     },
  #   :storage => :s3,
  #   :s3_credentials => "#{Rails.root.to_s}/config/paperclip-s3.rb",
  #   :path => ":attachment/:id/:style/:basename.:extension"

  def check_if_archived
    if self.is_archived?
      errors.add :base, 'Can not add or edit entries in an archived period'
      return false
    end
  end

  def is_archived?
    entity_id = self.account.entity_id
    entry_date = self.transaction_new.date
    dates = ArchiveDate.where("entity_id = #{entity_id} AND start_date <= '#{entry_date}' AND end_date >= '#{entry_date}'").first
    if dates
      true
    else
      false
    end
  end

  def blank?
    amount == 0 #&& description.empty? && attachment_file_name.nil?
  end

  def self.previous_entry(account_id,date)
    Entry.where("transactions.date <= '#{date}' AND
      entries.account_id = #{account_id}").order('transactions.date DESC, entries.id DESC').joins(:transaction_new).first
  end

  def previous_entry
    Entry.where("( transactions.date < '#{transaction_new.date}' OR
      (transactions.date = '#{transaction_new.date}' AND entries.id < #{id}) ) AND
      entries.account_id = #{account_id}").order('transactions.date DESC, entries.id DESC').joins(:transaction_new).first
  end

  def self.post_entries(account_id, date, id=nil)
    if id
      Entry.where("(
        transactions.date > ? OR
        ( transactions.date = ? AND
        entries.id > ? ) ) AND
        entries.account_id = ?", date, date, id, account_id).order('transactions.date ASC, entries.id ASC').joins(:transaction_new)
    else
      Entry.where("transactions.date > ? AND entries.account_id = ?", date, account_id).order('transactions.date ASC, entries.id ASC').joins(:transaction_new)
    end
  end

  def post_entries
    Entry.where("(
      transactions.date > ? OR
      ( transactions.date = ? AND
      entries.id > ? ) ) AND
      entries.account_id = ?", transaction.date, transaction.date, id, account_id).order('transactions.date ASC, entries.id ASC').joins(:transaction_new)
  end


  # This method used for correcting balances, by reprocessing all.
  def self.reprocess_balances(entity_id)
    accounts = Account.find_all_by_entity_id(entity_id)
    accounts.each do |a|
      entries = Entry.find_all_by_account_id(a, :joins => :transaction_new, :order => 'transactions.date ASC, id ASC')
      previous_balance = 0
      entries.each do |e|
        Entry.find_by_sql("UPDATE entries SET balance = #{ previous_balance + e.amount } WHERE id = #{e.id}")
        previous_balance += e.amount
      end
    end
  end

  def self.reprocess_account_balances(account_id, date)
    account = Account.find(account_id)

    entries = Entry.where(:account_id => account.id).where("date >= ?",date).joins(:transaction_new).order('transactions.date ASC, id ASC')
    previous_balance = entries.first.previous_entry&.balance || 0
    entries.each do |e|
      Entry.find_by_sql("UPDATE entries SET balance = #{ previous_balance + e.amount } WHERE id = #{e.id}")
      previous_balance += e.amount
    end

  end

  def self.find_entries(search)
    #FIXME Search for example numbers with decimals broken
    entries = []
    search.elements.each do |e|
      if numeric?(e.element)
        entries += Entry.
          where("accounts.entity_id = ?", search.entity_id).
          where("CAST(amount as CHAR) LIKE '%#{e.element}%' OR amount = #{e.element.to_f}").
          joins(:account, :transaction_new).
          order ("transactions.date DESC")
      else
        entries += Entry.
          where("accounts.entity_id = ?", search.entity_id).
          where("LOWER(entries.description) LIKE LOWER('%#{e.element}%')").
          joins(:account)
          # joins(:account, :transaction).
          # order ("transactions.date DESC")
      end
    end
    return entries
  end

  private

  def self.numeric?(object)
    true if Float(object) rescue false
  end

  def self.rebalance(hash) # :entry, :entries, :account_id, :id, :date
    entries = []
    if hash[:entry]
      entries.push(hash[:entry])
    elsif hash[:entries]
      entries = hash[:entries]
    elsif hash[:account_id] && hash[:id] && hash[:date]
      entries = Entry.post_entries(hash[:account_id], hash[:date], hash[:id])
    elsif hash[:account_id] && hash[:date]
      entries = Entry.post_entries(hash[:account_id], hash[:date])
    end
    if entries[0]
      if hash[:previous_balance]
        previous_balance = hash[:previous_balance]
      else
        previous_balance = entries[0].previous_entry ? entries[0].previous_entry.balance : 0
      end
      #entries.each { |entry| Entry.find_by_sql("UPDATE entries SET balance = #{ previous_balance += entry.amount } WHERE id = #{entry.id}")}
      entries.each do |entry|
        ActiveRecord::Base.connection.execute("UPDATE entries SET balance = #{ previous_balance += entry.amount } WHERE id = #{entry.id}")
      end
    end
  end

  def update_balances
    return if self.blank?
    if new_record?
      if self.class.previous_entry(self.account_id, self.transaction_new.date)
        previous_balance = self.class.previous_entry(self.account_id, self.transaction_new.date).balance
      else
        previous_balance = 0
      end
      self.balance = previous_balance + amount
      self.class.rebalance(:account_id => self.account_id, :date => self.transaction_new.date, :previous_balance => self.balance)
    elsif destroyed?
      self.class.rebalance(:account_id => self.account_id, :id => self.id, :date => self.transaction_new.date)
    elsif changed?

      if account_id_changed?
        self.class.rebalance(:account_id => self.account_id_was, :id => self.id, :date => self.transaction_new.date)
        previous_account = Account.find(self.account_id_was)
        if previous_account.class == 'IncomeAccount' || previous_account.class == 'ExpenseAccount'
          related_retained_earnings_entry = Entry.where(:related_entry_id => self.id)
          related_retained_earnings_entry.destroy if related_retained_earning_entry
        end
      end

      if self.previous_entry
        previous_balance = self.previous_entry.balance
      else
        previous_balance = 0
      end
      self.balance = previous_balance + amount
      self.class.rebalance(:account_id => self.account_id, :date => self.transaction_new.date, :previous_balance => self.balance)
    end
    return true
  end

  def clone_income_and_expense_to_equity
    if account.class == IncomeAccount
      retained_earnings_account = EquityAccount.find(entity.retained_earnings_account_id)
      cloned_entry = Entry.find_or_initialize_by(related_entry_id: self.id, transaction_id: self.transaction_id)
      cloned_entry.account_id = retained_earnings_account.id
      cloned_entry.amount = self.amount
      cloned_entry.description = self.description
      cloned_entry.entry_type = 'Closing'
      cloned_entry.save

    elsif account.class == ExpenseAccount
      retained_earnings_account = EquityAccount.find(entity.retained_earnings_account_id)
      cloned_entry = Entry.find_or_initialize_by(related_entry_id: self.id, transaction_id: self.transaction_id)
      cloned_entry.account_id = retained_earnings_account.id
      cloned_entry.amount = -self.amount
      cloned_entry.description = self.description
      cloned_entry.entry_type = 'Closing'
      cloned_entry.save

    elsif account_id_changed? && !account_id_was.nil? && (
        Account.find(self.account_id_was).class == IncomeAccount ||
        Account.find(self.account_id_was).class == ExpenseAccount
        )

      cloned_entry = Entry.find_by_related_entry_id_and_transaction_id(self.id, self.transaction_id)
      cloned_entry.destroy
    else
    end
  end


end
