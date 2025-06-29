class CreateEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :entities do |t|
      t.string :name, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.boolean :is_archived, default: false
      t.integer :retained_earnings_account_id
    end
  end
end
