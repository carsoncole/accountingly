class CreateArchiveDates < ActiveRecord::Migration[8.0]
  def change
    create_table :archive_dates do |t|
      t.integer  "entity_id"
      t.date     "start_date"
      t.date     "end_date"

      t.timestamps
    end
  end
end
