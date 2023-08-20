defmodule AllThingsSocialWeb.ContentBoardLive.Show do
  use AllThingsSocialWeb, :brand_live_view

  alias AllThingsSocial.ContentBoards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    potential_influencer_accounts =
      ContentBoards.list_potential_influencer_accounts_for_a_content_board(id)

    outreached_influencer_accounts =
      ContentBoards.list_outreached_influencer_accounts_for_a_content_board(id)

    negotiating_influencer_accounts =
      ContentBoards.list_negotiating_influencer_accounts_for_a_content_board(id)

    active_influencer_accounts =
      ContentBoards.list_active_influencer_accounts_for_a_content_board(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:potential_influencer_accounts, potential_influencer_accounts)
     |> assign(:outreached_influencer_accounts, outreached_influencer_accounts)
     |> assign(:negotiating_influencer_accounts, negotiating_influencer_accounts)
     |> assign(:active_influencer_accounts, active_influencer_accounts)
     |> assign(:content_board, ContentBoards.get_content_board!(id))}
  end

  defp page_title(:show), do: "Show Content board"
  defp page_title(:edit), do: "Edit Content board"
end
