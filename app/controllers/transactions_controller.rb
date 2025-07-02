class TransactionsController < BaseController
  before_action :set_transaction, only: [ :show, :edit, :update, :destroy ]
  after_action :set_last_use_entity!, only: :index

  def index
    @entity = helpers.entity
    if helpers.entity
      @pagy, @transactions = pagy(helpers.entity.transactions.includes(:entries).order("date DESC"))
    else
      redirect_to entities_path
    end
  end

  def show
    @entity = helpers.entity
  end

  def search
    if is_number?(params[:search])
      @transactions = Transaction.where([ "entity_id = ? AND entries.amount LIKE ?", helpers.entity.id,
        "%"+params[:search]+"%" ]).includes(:entries).order("date DESC, transactions.id DESC").
          paginate(page: params[:page], per_page: 20)
    elsif params[:search][0..7].downcase == "account:"
      account_name = params[:search][8..-1].downcase.strip
      account = entity.accounts.find(:first, conditions: "name LIKE '%#{account_name}%'")
      if account
        redirect_to entity_account_entries_path(entity, account) and return
      end
    else @transactions = Transaction.where([ "entity_id = ? AND LOWER(transactions.description) LIKE LOWER(?)", entity.id,
      "%"+params[:search]+"%" ]).order("date DESC,transactions.id DESC").paginate(page: params[:page],
        per_page: 20)
    end
    @query = params[:search]
    render "index"
  end

  def number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def new
    redirect_to entity_transactions_path(entity) unless writer? || administrator?
    @transaction = entity.transactions.build
    @transaction.entries.build
    @transaction.date = Date.today
    10.times { @transaction.entries.build }
  end

  def edit
    redirect_to entity_transactions_path(entity) unless writer? || administrator?
    @transaction.entries.reject { |e|  e.account.class == EquityAccount && e.account.name == "Retained earnings" }
    4.times { @transaction.entries.build }
  end

  # FIXME: This is not working
  def create
    redirect_to entity_transactions_path(entity) unless writer? || administrator?
    @transaction = entity.transactions.new(transaction_params)
    @transaction.created_by = Current.user.id
    @transaction.updated_by = Current.user.id
    @transaction.entries.each { |e| e.entry_type = "Regular" }
    @transaction.entries = @transaction.entries.reject { |e| e.account_id.nil? }
    if @transaction.entries.empty?
      redirect_to new_entity_transaction_path(entity), alert: "No transaction posted"
    elsif @transaction.save
      redirect_to entity_transaction_path(entity, @transaction), notice: "Transaction was successfully saved"
    else
      # @transaction.entries.each { |entry| entry.errors.each { |key,value| @transaction.errors[:key] = value } }
      4.times { @transaction.entries.build }
      render :new, status: :unprocessable_entity
    end
  end

  def update
    redirect_to entity_transactions_path(entity) unless writer? || administrator?
    @transaction.updated_by = Current.user.id

    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to entity_transaction_path(entity, @transaction), notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        @transaction.entries.reject { |e|  e.account.class == EquityAccount && e.account.name == "Retained earnings" }
        4.times { @transaction.entries.build }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def count_per_page
    count = 20
    if params[:format] == "csv"
      count = 9999
    end
    count
  end

  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to entity_transactions_path(entity), status: :see_other, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def is_number?(query)
    query.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def is_account?(query)
    query.match(/account:/) == nil ? false : true
  end

  def self.related_accounts(query)
    @query_accounts = []
    @query_accounts << Account.find(:all, conditions: "'#{query}' LIKE LOWER(name)")
  end

  def get_account(query)
    account_name = query.match(/.*account:(.*)/)[1].lstrip
    account = entity.accounts.where("LOWER(name) LIKE ?", "%#{account_name}%").first
    account
  end

  private

  def set_transaction
    @transaction = entity.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit!
    # params.require(:transaction).permit(:date, :description, entries_attributes: [:id, :account_id, :amount, :description, :attachment, :_destroy])
  end
end
