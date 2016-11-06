class MazeResult < ActiveRecord::Base
  belongs_to :maze_user
  validates :elapsed_mcs, :steps, :level_id, :presence => true

  def place_for_steps
    return 1 + MazeResult.where(level_id: self.level_id)
                         .where("steps < ?", self.steps)
                         .select(:user)
                         .distinct
                         .count
  end

  def place_for_time
    return 1 + MazeResult.where(level_id: self.level_id)
                         .where("elapsed_mcs < ?", self.elapsed_mcs)
                         .select(:user)
                         .distinct
                         .count
  end
end
