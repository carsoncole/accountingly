class IncomeStatement < Statement
  attr_reader :account_balances, :incomes, :expenses, :total_incomes, :total_expenses, :gross_profit, :net_profit
  attr_accessor :from_date, :to_date, :entity

  def self.sdates(from_date, to_date)
    starting_month = from_date.month
    ending_month = to_date.month
    dates = []
    (starting_month..ending_month).each do |m|
      if m == starting_month
        dates << [ from_date, Date.civil(from_date.year, m, -1) ]
      else
        dates << [ Date.civil(from_date.year, m, 1), Date.civil(from_date.year, m, -1) ]
      end
    end
    dates
  end


  def initialize(entity, from_date, to_date = Date.today)
    super
    @account_balances = {}

    entity.accounts.each do |account|
      account_total = 0
      entries = Entry.where("account_id = #{account.id} AND
      date <= '#{to_date}' AND
      date >= '#{from_date}' AND
      entry_type <> 'Closing'").joins(:transaction_new)
      entries.each do |entry|
        account_total += entry.amount
      end
      unless account_total.nil? || account_total == 0
        @account_balances[account] = account_total
      end
    end
  end

  def income
    total = 0
    self.account_balances.each do |account, value|
      total += value if account.class == IncomeAccount
    end
    total
  end

  def expense
    total = 0
    self.account_balances.each do |account, value|
      total += value if account.class == ExpenseAccount
    end
    total
  end

  def net_income
    income - expense
  end

  def self.sections
    [ :Income, :Expense ]
  end

  def incomes
    income_accounts = {}
    self.account_balances.each { |account, value| income_accounts[account] = value if account.class == IncomeAccount }
    income_accounts
  end

  def expenses
    expense_accounts = {}
    self.account_balances.each { |account, value| expense_accounts[account] = value if account.class == ExpenseAccount }
    expense_accounts
  end

  def accounts
    account_balances.map { |account, value| account }
  end

  def self.collection(entity, periods)
    collection = []
    periods.each do |from_date, to_date|
      collection << IncomeStatement.new(entity, from_date, to_date)
    end
    collection
  end
end
