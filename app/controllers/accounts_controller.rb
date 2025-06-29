class AccountsController < BaseController

  def index
    @asset_accounts = entity.asset_accounts.order(:name)
    @liability_accounts = entity.liability_accounts.order(:name)
    @equity_accounts = entity.equity_accounts.order(:name)
    @income_accounts = entity.income_accounts.order(:name)
    @expense_accounts = entity.expense_accounts.order(:name)
  end

  def show
    @account = entity.accounts.find(params[:id])
    @balance = @account.balance
  end

  def edit
    redirect_to entity_accounts_path(entity) unless Current.user.administrator?(entity)
    @account = entity.accounts.find(params[:id])
  end

  def new
    redirect_to entity_accounts_path(entity) unless Current.user.administrator?(entity)
    @account = entity.accounts.build
  end

  def update
    redirect_to entity_accounts_path(entity) unless Current.user.administrator?(entity)
    @account = entity.accounts.find(params[:id])
    if @account.update(account_params)
      redirect_to(entity_accounts_path(entity), :notice => 'Account modification saved')
    else
      redirect_to(:back)
    end
  end

  def destroy
    redirect_to entity_accounts_path(entity) unless Current.user.administrator?(entity)
    @account = entity.accounts.find(params[:id])
    redirect_to(entity_accounts_path(entity), :notice => "Account can not be destroyed") if @account.name == 'Retained earnings'
    @account.destroy
    redirect_to(entity_accounts_path(entity), :notice => "Successfully deleted")
  end

  def create
    case params[:account][:type]
    when 'Asset'
      @account = AssetAccount.new
    when 'Liability'
      @account = LiabilityAccount.new
    when 'Income'
      @account = IncomeAccount.new
    when 'Expense'
      @account = ExpenseAccount.new
    when 'Equity'
      @account = EquityAccount.new
    end
    if @account
      @account.entity_id = entity.id
      @account.name = params[:account][:name]
      if @account.save
        redirect_to(entity_accounts_path(entity), :notice => "#{@account.name} created")
      else
        render :edit
      end
    end
  end

  def account_params
    params.require(:account).permit!
  end

end
