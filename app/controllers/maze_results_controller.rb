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
    @maze_results = MazeResult.find_by_sql("select t0.elapsed_mcs as elapsed_mcs, t0.maze_user_id as maze_user_id, min(t0.created_at) as created_at from maze_results t0 join (select t.maze_user_id, min(t.elapsed_mcs) as elapsed_mcs from maze_results t where level_id=#{ActiveRecord::Base.connection.quote(@level_id)} group by (t.maze_user_id)) t1 on t0.maze_user_id=t1.maze_user_id and t0.elapsed_mcs=t1.elapsed_mcs group by (t0.maze_user_id, t0.elapsed_mcs) order by t0.elapsed_mcs asc, min(t0.created_at) asc")
    @criteria = 'времени'
    render 'top'
  end
  def top_steps
    @level_id = params.require(:level_id)
    @maze_results = MazeResult.find_by_sql("select t0.steps as steps, t0.maze_user_id as maze_user_id, min(t0.created_at) as created_at from maze_results t0 join (select t.maze_user_id, min(t.steps) as steps from maze_results t where level_id=#{ActiveRecord::Base.connection.quote(@level_id)} group by (t.maze_user_id)) t1 on t0.maze_user_id=t1.maze_user_id and t0.steps=t1.steps group by (t0.maze_user_id, t0.steps) order by t0.steps asc, min(t0.created_at) asc")
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
