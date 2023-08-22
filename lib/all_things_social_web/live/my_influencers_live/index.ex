defmodule AllThingsSocialWeb.MyInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount
  alias AllThingsSocial.Brands
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Influencers

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

    niches =
      Niches.list_niches()
      |> Enum.uniq(fn niche -> niche.name end)
      |> Enum.map(fn niche ->
        niche
        {niche.name, niche.name}
      end)

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(
       :search_changeset,
       InfluencerAccounts.change_influencer_account(%InfluencerAccount{})
     )
     |> assign(
       :niche_changeset,
       InfluencerAccounts.change_influencer_account(%InfluencerAccount{})
     )
     |> assign(:niches, niches)
     |> assign(:influencer_account_id, infuencer_account_id)
     |> assign(:influencer_accounts, influencer_accounts)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", %{"influencer_account" => influencer_account_params}, socket) do
    {:noreply,
     socket
     |> assign(
       :influencers,
       Influencers.list_influencers_by_search(influencer_account_params["search"])
     )}
  end

  def handle_event("search_niche", %{"influencer_account" => influencer_account_params}, socket) do
    {:noreply,
     socket
     |> assign(
       :influencers,
       Influencers.list_influencers_by_niches(influencer_account_params["search"])
     )}
  end
end
