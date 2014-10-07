class AddEstimatedFeetToResult < ActiveRecord::Migration
  def change
    add_column :results, :estimated_feet, :float
  end
end
