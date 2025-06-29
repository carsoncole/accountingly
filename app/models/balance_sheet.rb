class BalanceSheet < Statement
  attr_accessor :entity, :to_date, :from_date
  attr_reader :account_balances, :assets, :liabilities, :equities, :total_assets, :total_liabilities, :total_equities


  def initialize(entity,from_date,to_date=Date.today)
    super
    @account_balances = {}

    entity.accounts.each do |account|
      account_total = 0
      last_entry = Entry.where("account_id = #{account.id} AND date <= '#{to_date}'").order("date DESC, id DESC").joins(:transaction_new).limit(1).first
      unless last_entry.nil?  || last_entry.balance == 0
        @account_balances[account] = last_entry.balance
      end
    end

  end

  def self.sections
    [:Asset, :Liability, :Equity]
  end

  def assets
    asset_accounts = {}
    self.account_balances.each { |account, value| asset_accounts[account] = value if
      account.class == AssetAccount &&
      value != 0 }
    return asset_accounts
  end

  def liabilities
    liability_accounts = {}
    self.account_balances.each { |account, value| liability_accounts[account] = value if
      account.class == LiabilityAccount &&
      value != 0 }
    return liability_accounts
  end

  def equities
    equity_accounts = {}
    self.account_balances.each { |account, value| equity_accounts[account] = value if
      account.class == EquityAccount &&
      value != 0 }
    return equity_accounts
  end


  def self.collection(entity, periods )
    collection = []
    periods.each do |from_date, to_date|
      collection << BalanceSheet.new(entity, from_date, to_date)
    end
    return collection
  end


end
