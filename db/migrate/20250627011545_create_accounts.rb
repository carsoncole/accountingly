class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.integer :entity_id
      t.string :name
      t.string :note
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :rank, default: 1
      t.string :type
    end
  end
end
