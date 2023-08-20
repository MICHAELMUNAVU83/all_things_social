defmodule AllThingsSocialWeb.PageLive.Index do
  use AllThingsSocialWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "All Things Social")}
  end
end
