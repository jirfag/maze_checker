class CreateMazeUsers < ActiveRecord::Migration
  def change
    create_table :maze_users do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
