defmodule AllThingsSocialWeb.NicheLive.Index do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.Niches
  alias AllThingsSocial.Niches.Niche
  alias AllThingsSocial.Influencers

  @impl true
  def mount(_params, session, socket) do
    logged_in_influencer =
      Influencers.get_influencer_by_session_token(session["influencer_token"])

    {:ok,
     socket
     |> assign(:niches, list_niches())
     |> assign(:page_title, "Listing Niches")
     |> assign(:logged_in_influencer, logged_in_influencer)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Niche")
    |> assign(:niche, Niches.get_niche!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Niche")
    |> assign(:niche, %Niche{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Niches")
    |> assign(:niche, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    niche = Niches.get_niche!(id)
    {:ok, _} = Niches.delete_niche(niche)

    {:noreply, assign(socket, :niches, list_niches())}
  end

  defp list_niches do
    Niches.list_niches()
  end
end
