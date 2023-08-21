defmodule AllThingsSocialWeb.InfluencerDashboardLive.Index do
  use AllThingsSocialWeb, :live_view
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.SocialMediaAccounts
  alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount
  alias AllThingsSocial.Rates
  alias AllThingsSocial.Rates.Rate
  alias AllThingsSocial.Niches
  alias AllThingsSocial.Niches.Niche

  def mount(params, session, socket) do
    logged_in_influencer =
      Influencers.get_influencer_by_session_token(session["influencer_token"])

    {:ok,
     socket
     |> assign(:social_media_account, %SocialMediaAccount{})
     |> assign(:rate, %Rate{})
     |> assign(:niche, %Niche{})
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:add_social_media_account), do: "Add Social media account"
  defp page_title(:index), do: "Index"
  defp page_title(:add_rate), do: "Add Rate"
  defp page_title(:add_niche), do: "Add Niche"
end
