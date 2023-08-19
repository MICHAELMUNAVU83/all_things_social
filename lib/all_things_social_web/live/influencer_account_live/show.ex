defmodule AllThingsSocialWeb.InfluencerAccountLive.Show do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.InfluencerAccounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:influencer_account, InfluencerAccounts.get_influencer_account!(id))}
  end

  defp page_title(:show), do: "Show Influencer account"
  defp page_title(:edit), do: "Edit Influencer account"
end
