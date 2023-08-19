defmodule AllThingsSocialWeb.InfluencerAccountLive.Index do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.InfluencerAccounts
  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :influencer_accounts, list_influencer_accounts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Influencer account")
    |> assign(:influencer_account, InfluencerAccounts.get_influencer_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Influencer account")
    |> assign(:influencer_account, %InfluencerAccount{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Influencer accounts")
    |> assign(:influencer_account, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    influencer_account = InfluencerAccounts.get_influencer_account!(id)
    {:ok, _} = InfluencerAccounts.delete_influencer_account(influencer_account)

    {:noreply, assign(socket, :influencer_accounts, list_influencer_accounts())}
  end

  defp list_influencer_accounts do
    InfluencerAccounts.list_influencer_accounts()
  end
end
