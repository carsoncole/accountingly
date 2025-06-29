class CreateAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :accesses do |t|
      t.integer :user_id
      t.integer :entity_id
      t.string :type

      t.timestamps
    end
  end
end
