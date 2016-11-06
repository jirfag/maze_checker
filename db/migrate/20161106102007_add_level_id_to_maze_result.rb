class AddLevelIdToMazeResult < ActiveRecord::Migration
  def change
    add_column :maze_results, :level_id, :string
  end
end
