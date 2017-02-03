defmodule Frozen.PageController do
  use Frozen.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
