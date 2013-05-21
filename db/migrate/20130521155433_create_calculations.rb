class CreateCalculations < ActiveRecord::Migration
  def change
    create_table :calculations do |t|
      t.string :library_code
      t.string :call_num_start
      t.string :call_num_end
      t.integer :travel_time

      t.timestamps
    end
  end
end
