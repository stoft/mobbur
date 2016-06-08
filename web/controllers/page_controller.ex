defmodule Mobbur.PageController do
  use Mobbur.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
