class CreateCalculations < ActiveRecord::Migration
  def change
    create_table :calculations do |t|
      t.string :library_code
      t.string :collection_code
      t.string :call_num_start
      t.string :call_num_end
      t.float :travel_time
      t.float :avg_feet_moved_per_trip
      t.float :load_time
      t.float :unload_time


      t.timestamps
    end
  end
end
