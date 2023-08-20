defmodule AllThingsSocialWeb.MyInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts

  def mount(_params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    content_boards = ContentBoards.list_content_boards_for_a_brand(logged_in_brand.id)

    influencer_accounts =
      InfluencerAccounts.list_influencer_accounts_for_a_brand(logged_in_brand.id)

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(:influencer_accounts, influencer_accounts)
     |> assign(:content_boards, content_boards)}
  end
end
