defmodule AllThingsSocialWeb.SocialMediaAccountLive.Show do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.SocialMediaAccounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:social_media_account, SocialMediaAccounts.get_social_media_account!(id))}
  end

  defp page_title(:show), do: "Show Social media account"
  defp page_title(:edit), do: "Edit Social media account"
end
