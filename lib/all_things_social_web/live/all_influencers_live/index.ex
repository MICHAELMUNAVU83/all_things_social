defmodule AllThingsSocialWeb.AllInfluencersLive.Index do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Influencers.Influencer
  alias AllThingsSocial.Brands
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Rates
  alias AllThingsSocial.ContentBoards
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount
  alias AllThingsSocial.SocialMediaAccounts

  def mount(params, session, socket) do
    influencers = Influencers.list_influencers()
    IO.inspect(params)

    influencer_id =
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

    niches =
      Niches.list_niches()
      |> Enum.uniq(fn niche -> niche.name end)
      |> Enum.map(fn niche ->
        niche
        {niche.name, niche.name}
      end)

    niches = [{"All Niches", ""}] ++ niches

    social_media_accounts =
      if influencer_id != "" do
        SocialMediaAccounts.list_social_media_accounts()
        |> Enum.filter(fn social_media_account ->
          social_media_account.influencer_id == String.to_integer(influencer_id)
        end)
      else
        []
      end

    rates =
      if influencer_id != "" do
        Rates.list_rates()
        |> Enum.filter(fn rate ->
          rate.influencer_id == String.to_integer(influencer_id)
        end)
      else
        []
      end

    all_niches =
      if influencer_id != "" do
        Niches.list_niches()
        |> Enum.filter(fn niche ->
          niche.influencer_id == String.to_integer(influencer_id)
        end)
      else
        []
      end

    {:ok,
     socket
     |> assign(:influencers, influencers)
     |> assign(:page_title, "Listing Influencers")
     |> assign(:influencer_id, influencer_id)
     |> assign(:social_media_accounts, social_media_accounts)
     |> assign(:content_boards, content_boards)
     |> assign(
       :search_changeset,
       InfluencerAccounts.change_influencer_account(%InfluencerAccount{})
     )
     |> assign(
       :niche_changeset,
       InfluencerAccounts.change_influencer_account(%InfluencerAccount{})
     )
     |> assign(:niches, niches)
     |> assign(:all_niches, all_niches)
     |> assign(:rates, rates)
     |> assign(:state, "social_media_accounts")
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(:influencer_account, %InfluencerAccount{})}
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

  def handle_event("change_state", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:state, id)}
  end
end
