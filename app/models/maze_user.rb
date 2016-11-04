class MazeUser < ActiveRecord::Base
  has_many :maze_results
end
