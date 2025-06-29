class AddIndexEntityIdAndDateOnTransactions < ActiveRecord::Migration[8.0]
  def change
    add_index :transactions, [:entity_id, :date], order: {date: :desc}, name: 'entity_id_on_trans'
  end
end
