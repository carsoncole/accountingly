class EntriesController < BaseController

  def count_per_page
    15
  end

  def index
    @account = entity.accounts.find(params[:account_id])
    @title = Account.find(params[:account_id]).name
    if params[:order] == 'asc'
      @pagy, @entries = pagy(
        @account.entries.
        joins(:transaction_new).
        order("transactions.date ASC, entries.id ASC")
        )
    else
        @pagy, @entries = pagy(
          @account.entries.
          joins(:transaction_new ).
          order("transactions.date DESC, entries.id DESC")
          )
    end
    @query = "Account:" + @title
  end

  def compare
    @account = entity.accounts.find(params[:account_id])
    @title = Account.find(params[:account_id]).name
    if params[:order] == 'asc'
      @entries = @account.entries.
        page(params[:page]).
        joins(:transaction ).
        order("transactions.date ASC, transactions.id ASC")
    else
        @entries = @account.entries.
          page(params[:page]).
          joins(:transaction ).
          order("transactions.date DESC, transactions.id DESC")
    end
    @query = "Account:" + @title

  end

  private

  def entry_params
    params.require(:entry).permit(:amount, :balance, :account_id, :description,:attachment_file_name, :attachment, :transaction_id)
  end

end
