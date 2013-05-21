class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.text :pages
      t.text :serials
      t.text :multi_volumes
      t.integer :records_without_pages
      t.float :cm_per_serial
      t.float :cm_per_volume
      t.integer :total_records
      t.references :calculation

      t.timestamps
    end
    add_index :results, :calculation_id
  end
end
