class Account < ApplicationRecord

  TYPES = [
      'Asset',
      'Liability',
      'Income',
      'Expense',
      'Equity'
    ]

  has_many :entries
  belongs_to :entity
  validates :name, :entity_id, :presence => true
  validates :name, :length => { :maximum => 30 }
  validates_numericality_of :rank

  def archived?(date)
    ArchiveDate.where("entity_id= ? AND start_date <= ? AND end_date >= ?",
        entity_id, date, date).any? ? true : false
  end

  def addition_or_subtraction
    case type
    when 'AssetAccount', 'ExpenseAccount'
      1
    when 'LiabilityAccount', 'IncomeAccount', 'EquityAccount'
      -1
    else
      1
    end
  end

  def self.type
    to_s.gsub('Account', '')
  end

  def self.total_assets(args)
    accounts = AssetAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def self.total_liabilities(args)
    accounts = LiabilityAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def self.total_equity(args)
    accounts = EquityAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def self.total_liabilities_and_equity(args)
    total_liabilities({:date => args[:date], :entity_id => args[:entity_id]}) + total_equity({:date => args[:date], :entity_id => args[:entity_id]})
  end

  def balance(date=(Time.now.year.to_s+'-'+Time.now.month.to_s+'-'+Time.now.day.to_s))
    last_entry = Entry.where("account_id=#{self.id} AND transactions.date <= '#{date}'").
      joins(:transaction_new).order("date DESC, id DESC").first
    if last_entry
      balance = last_entry.balance
    else
      balance = 0
    end
    return balance
  end

  def self.find_accounts(search)
    accounts = []
    search.elements.each do |e|
      accounts += Account.
        where(:entity_id =>search.entity_id).
        where("LOWER(name) LIKE LOWER('%#{e.element}%')")
    end
    return accounts
  end

  def disallow_type_change!
    errors[:base] << "can not be changed"
    false
  end

end
