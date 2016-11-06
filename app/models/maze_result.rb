class MazeResult < ActiveRecord::Base
  belongs_to :maze_user
  validates :elapsed_mcs, :steps, :level_id, :presence => true
end
