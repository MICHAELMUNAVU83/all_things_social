defmodule AllThingsSocialWeb.PageController do
  use AllThingsSocialWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
