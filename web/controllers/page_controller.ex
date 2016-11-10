defmodule Mobbur.PageController do
  use Mobbur.Web, :controller

  import Mobbur.TeamNameGenerator

  def index(conn, %{"page" => page} = params) do
    IO.puts "Controller:"
    IO.inspect conn
    render conn, "index.html", [uuid: page, team_name: generate_name]
  end

  def index(conn, params) do
    newUUID = UUID.uuid1()

    redirect conn, to: "/#{newUUID}"
  end

end
