defmodule AllThingsSocialWeb.ContentBoardLive.Show do
  use AllThingsSocialWeb, :brand_live_view

  alias AllThingsSocial.ContentBoards
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    id = params["id"]
    IO.inspect(params)

    IO.inspect(InfluencerAccounts.list_influencer_accounts())

    potential_influencer_accounts =
      ContentBoards.list_potential_influencer_accounts_for_a_content_board(id)

    outreached_influencer_accounts =
      ContentBoards.list_outreached_influencer_accounts_for_a_content_board(id)

    negotiating_influencer_accounts =
      ContentBoards.list_negotiating_influencer_accounts_for_a_content_board(id)

    active_influencer_accounts =
      ContentBoards.list_active_influencer_accounts_for_a_content_board(id)

    influencer_account_id =
      if params["influencer_account_id"] != nil do
        params["influencer_account_id"]
      else
        ""
      end

    influencer_account =
      if influencer_account_id != "" do
        InfluencerAccounts.get_influencer_account!(influencer_account_id)
      else
        %InfluencerAccount{}
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:influencer_account, influencer_account)
     |> assign(:influencer_account_id, influencer_account_id)
     |> assign(:potential_influencer_accounts, potential_influencer_accounts)
     |> assign(:outreached_influencer_accounts, outreached_influencer_accounts)
     |> assign(:negotiating_influencer_accounts, negotiating_influencer_accounts)
     |> assign(:changeset, InfluencerAccounts.change_influencer_account(influencer_account))
     |> assign(:active_influencer_accounts, active_influencer_accounts)
     |> assign(:content_board, ContentBoards.get_content_board!(id))}
  end

  defp page_title(:show), do: "Show Content board"
  defp page_title(:edit), do: "Edit Content board"
  defp page_title(:editinfluenceraccount), do: "Edit"
end
