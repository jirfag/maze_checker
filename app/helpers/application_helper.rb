module ApplicationHelper
  def link_to_user(maze_user_id)
    user_name = MazeUser.find(maze_user_id).name
    short_user_name = user_name.gsub(/^([^\/]+)\/.+$/, '\1')
    return link_to short_user_name, "https://github.com/#{user_name}"
  end
end
