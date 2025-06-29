class Entity < ApplicationRecord

  has_many :accounts, :dependent => :destroy
  has_many :asset_accounts
  has_many :liability_accounts
  has_many :equity_accounts
  has_many :income_accounts
  has_many :expense_accounts

  has_many :accesses, :dependent => :destroy
  has_many :users, :through => :accesses
  has_many :transactions, :dependent => :destroy
  has_many :archive_dates, :dependent => :destroy
  has_many :entries, :through => :transactions

  belongs_to :retained_earnings_account, :class_name => 'Account', optional: true

  validates :name, :presence => true, :length => { :minimum => 2, :maximum => 35 }

  after_create :add_basic_set_of_accounts!
  validate :retained_earnings_account_id_unchanged, :if => Proc.new { |e| e.retained_earnings_account_id_changed? }

  scope :active, -> { where(:is_archived => false) }

  def self.total_assets(args)
    accounts = AssetAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def total_liabilities(args)
    accounts = LiabilityAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def total_equity(args)
    accounts = EquityAccount.where(["entity_id = ?", args[:entity_id]] )
    total = 0
    accounts.each { |a| total +=  a.balance(args[:date]) }
    return total
  end

  def total_liabilities_and_equity(args)
    total_liabilities({:date => args[:date], :entity_id => args[:entity_id]}) + total_equity({:date => args[:date], :entity_id => args[:entity_id]})
  end

  private

  def add_basic_set_of_accounts!
    AssetAccount.create(:entity_id => id, :name => :Cash)
    ExpenseAccount.where(entity_id: id, name: :Expense).first_or_create
    LiabilityAccount.where(entity_id: id, name: :Liability).first_or_create
    IncomeAccount.where(entity_id: id, name: :Income).first_or_create
    equity_account = EquityAccount.where(entity_id: id, name: 'Retained earnings').first_or_create
    self.update_attribute(:retained_earnings_account_id, equity_account.id)
  end

  def retained_earnings_account_id_unchanged
    errors.add :retained_earnings_account_id, "can not be changed"
  end
end
