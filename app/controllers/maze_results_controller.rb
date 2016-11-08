require 'octokit'

class MazeResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end
  def index
    @maze_results = MazeResult.all
  end
  def create
    if params.require(:steps).to_i <= 10 || params.require(:elapsed_mcs).to_i <= 100 then
      # Hack was detected
      render :json => {status: 500}
      return
    end

    @maze_user = MazeUser.find_or_create_by(name: params.require(:user))
    @maze_result = @maze_user.maze_results.create(maze_result_params)
    add_pull_request_comment(@maze_result)
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
    def add_pull_request_comment(maze_result)
      message = "## Результат был зафиксирован\n" \
                "-  уровень **#{maze_result.level_id}**\n" \
                "- **#{maze_result.steps}** шагов\n" \
                "- **#{maze_result.elapsed_mcs}** мкс\n" \
                "- **#{maze_result.place_for_steps}** место по шагам (без учета одинаковых результатов)\n" \
                "- **#{maze_result.place_for_time}** место по времени (без учета одинаковых результатов)"
      client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']
      client.add_comment("jirfag/PREP-labyrinth", params.require(:pull_id), message)

      # Close PR to prevent pushing of hacks in next commits
      client.close_pull_request("jirfag/PREP-labyrinth", params.require(:pull_id))
    end
end
