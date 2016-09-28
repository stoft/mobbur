defmodule Mobbur.PageController do
  use Mobbur.Web, :controller

  def index(conn, %{"page" => page}) do
    IO.puts page
    render conn, "index.html"
  end

  def index(conn, params) do
    newUUID = UUID.uuid1()
    redirect conn, to: "/#{newUUID}"
  end
end
