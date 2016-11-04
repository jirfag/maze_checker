class CreateMazeResults < ActiveRecord::Migration
  def change
    create_table :maze_results do |t|
      t.integer :steps
      t.integer :elapsed_mcs
      t.references :maze_user, index: true

      t.timestamps null: false
    end
    add_foreign_key :maze_results, :maze_users
  end
end
