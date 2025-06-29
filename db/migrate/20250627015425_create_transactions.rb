class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :entity_id
      t.date :date
      t.string :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :created_by
      t.integer :updated_by
    end
  end
end
