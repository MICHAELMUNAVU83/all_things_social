defmodule AllThingsSocialWeb.ContentBoardLive.Show do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.ContentBoards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:content_board, ContentBoards.get_content_board!(id))}
  end

  defp page_title(:show), do: "Show Content board"
  defp page_title(:edit), do: "Edit Content board"
end
