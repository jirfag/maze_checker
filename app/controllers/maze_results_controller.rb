class MazeResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end
  def index
    @maze_results = MazeResult.all
  end
  def create
    @maze_user = MazeUser.find_or_create_by(name: params.require(:user))
    @maze_result = @maze_user.maze_results.create(maze_result_params)
    render :json => {}
  end
  def top_time
    @level_id = params.require(:level_id)
    @maze_results = MazeResult.where(level_id: @level_id).order(elapsed_mcs: :asc).select('DISTINCT ON (maze_user_id, elapsed_mcs) *')
    @criteria = 'времени'
    render 'top'
  end
  def top_steps
    @level_id = params.require(:level_id)
    @maze_results = MazeResult.where(level_id: @level_id).order(steps: :asc).select('DISTINCT ON (maze_user_id, steps) *')
    @criteria = 'числу шагов'
    render 'top'
  end
  private
    def maze_result_params
      params.permit(:steps, :elapsed_mcs, :level_id)
    end
end
