class AddIndexEntriesOnAccountId < ActiveRecord::Migration[8.0]
  def change
    add_index :entries, :account_id, name: 'account_id_on_entries'
    add_index :entries, :transaction_id, name: 'transaction_id_on_entries'

  end
end
