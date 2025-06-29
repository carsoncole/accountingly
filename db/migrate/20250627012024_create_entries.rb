class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.integer :transaction_id
      t.integer :account_id
      t.string :description
      t.decimal :amount, default: 0.0
      t.decimal :balance, default: 0.0
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.boolean :processed, default: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :entry_type
      t.integer :related_account_id
      t.integer :related_entry_id
      t.boolean :is_current, default: true
    end
  end
end
