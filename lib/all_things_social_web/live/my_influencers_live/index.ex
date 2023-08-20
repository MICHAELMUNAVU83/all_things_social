defmodule AllThingsSocialWeb.MyInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.Brands

  def mount(params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    influencer_accounts =
      InfluencerAccounts.list_influencer_accounts_for_a_brand(logged_in_brand.id)

    infuencer_account_id =
      if params["id"] != nil do
        params["id"]
      else
        ""
      end

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(:influencer_account_id, infuencer_account_id)
     |> assign(:influencer_accounts, influencer_accounts)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end
end
