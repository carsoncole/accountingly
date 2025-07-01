class StatementsController < ApplicationController
  before_action :require_authentication
  before_action :set_entity
  
  #TODO Add link to items making up account balance at certain time--COOL!
  def index
  end
  
  def balance_sheet
    @statement_to_date = Date.new(params[:to_date]['year'].to_i, 
      params[:to_date]['month'].to_i, params[:to_date]['day'].to_i)
    @statement_from_date = Date.new(params[:from_date]['year'].to_i,
      params[:from_date]['month'].to_i, params[:from_date]['day'].to_i)
    case params[:period].to_sym
      when :Custom
        @balance_sheets = BalanceSheet.collection(@entity,
          [[@statement_from_date, @statement_to_date]])
      when :Monthly
        dates = []
        @statement_from_date.month.upto(@statement_to_date.month).each do |date|
          if dates.empty?  
            dates << [@statement_from_date, Date.civil(@statement_from_date.year, @statement_from_date.month, -1)]
          else
            dates << [Date.civil(@statement_from_date.year, date, 1), Date.civil(@statement_from_date.year, date, -1)]
          end
          exit if date.month == 12
        end
        @balance_sheets = BalanceSheet.collection(@entity,dates)
      when :Yearly
    end
  
    @asset_accounts, @liability_accounts, @equity_accounts = {}, {}, {}
    @balance_sheets.each { |i| @asset_accounts.update(i.assets) }
    @balance_sheets.each { |i| @liability_accounts.update(i.liabilities) }
    @balance_sheets.each { |i| @equity_accounts.update(i.equities) }
    
  end
  
  def income_statement
    @statement_to_date = Date.new(params[:to_date]['year'].to_i, 
      params[:to_date]['month'].to_i, params[:to_date]['day'].to_i)
    @statement_from_date = Date.new(params[:from_date]['year'].to_i,
      params[:from_date]['month'].to_i, params[:from_date]['day'].to_i)
    case params[:period].to_sym
      when :Custom
        @income_statements = IncomeStatement.collection(@entity,
          [[@statement_from_date, @statement_to_date]])
      when :Monthly
        dates = []
        @statement_from_date.month.upto(@statement_to_date.month).each do |date|
          if dates.empty?  
            dates << [@statement_from_date, Date.civil(@statement_from_date.year, @statement_from_date.month, -1)]
          else
            dates << [Date.civil(@statement_from_date.year, date, 1), Date.civil(@statement_from_date.year, date, -1)]
          end
          next if date == 12
        end
        @income_statements = IncomeStatement.collection(@entity,dates)
      when :Yearly
    end
    
    @income_accounts, @expense_accounts = {}, {}
    @income_statements.each { |i| @income_accounts.update(i.incomes) }
    @income_statements.each { |i| @expense_accounts.update(i.expenses) }
  end
  
  private
  
  def set_entity
    @entity = Entity.find(params[:entity_id])
  end
end
