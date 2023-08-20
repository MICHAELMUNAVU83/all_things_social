defmodule AllThingsSocialWeb.SocialMediaAccountLive.Index do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.SocialMediaAccounts
  alias AllThingsSocial.Influencers
  alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount

  @impl true
  def mount(_params, session, socket) do
    logged_in_influencer =
      Influencers.get_influencer_by_session_token(session["influencer_token"])

    {:ok,
     socket
     |> assign(:social_media_accounts, list_social_media_accounts())
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Social media account")
    |> assign(:social_media_account, SocialMediaAccounts.get_social_media_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Social media account")
    |> assign(:social_media_account, %SocialMediaAccount{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Social media accounts")
    |> assign(:social_media_account, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    social_media_account = SocialMediaAccounts.get_social_media_account!(id)
    {:ok, _} = SocialMediaAccounts.delete_social_media_account(social_media_account)

    {:noreply, assign(socket, :social_media_accounts, list_social_media_accounts())}
  end

  defp list_social_media_accounts do
    SocialMediaAccounts.list_social_media_accounts()
  end
end
