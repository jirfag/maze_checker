class MazeResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end
  def index
    @maze_results = MazeResult.all
  end
  def create
    user_name = params[:user].gsub(/^([^\/]+)\/.+$/, '\1')
    @maze_user = MazeUser.find_or_create_by(name: user_name)
    @maze_result = @maze_user.maze_results.create(maze_result_params)
    render :json => {}
  end
  def top_time
    @maze_results = MazeResult.order(elapsed_mcs: :asc).select('DISTINCT ON (maze_user_id, elapsed_mcs) *')
    render 'top'
  end
  def top_steps
    @maze_results = MazeResult.order(steps: :asc).select('DISTINCT ON (maze_user_id, steps) *')
    render 'top'
  end
  private
    def maze_result_params
      params.permit(:steps, :elapsed_mcs)
    end
end
