defmodule AllThingsSocialWeb.MyInfluencersLive.Show do
  use AllThingsSocialWeb, :brand_live_view
  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.Brands

  def mount(_params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    influencer_account = InfluencerAccounts.get_influencer_account!(id)

    correct_brand =
      if socket.assigns.logged_in_brand.id == influencer_account.brand_id do
        true
      else
        false
      end

    {:noreply,
     socket
     |> assign(:influencer_account, InfluencerAccounts.get_influencer_account!(id))
     |> assign(:correct_brand, correct_brand)}
  end
end
