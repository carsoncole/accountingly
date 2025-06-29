class ChangeColumnAmountOnEntries < ActiveRecord::Migration[8.0]
  def change 
    change_column :entries, :amount, :decimal, precision: 11, scale: 2
    change_column :entries, :balance, :decimal, precision: 11, scale: 2
  end
end
