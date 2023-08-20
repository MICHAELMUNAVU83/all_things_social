defmodule AllThingsSocialWeb.AllInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Brands
  alias AllThingsSocial.ContentBoards
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount

  def mount(params, session, socket) do
    influencers = Influencers.list_influencers()
    IO.inspect(params)

    infuencer_id =
      if params["id"] != nil do
        params["id"]
      else
        ""
      end

    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    content_boards =
      ContentBoards.list_content_boards_for_a_brand(logged_in_brand.id)
      |> Enum.map(fn content_board ->
        content_board
        {content_board.name, content_board.id}
      end)

    IO.inspect(content_boards)

    {:ok,
     socket
     |> assign(:influencers, influencers)
     |> assign(:page_title, "Listing Influencers")
     |> assign(:influencer_id, infuencer_id)
     |> assign(:content_boards, content_boards)
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(:influencer_account, %InfluencerAccount{})}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end
end
