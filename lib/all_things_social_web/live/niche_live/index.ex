defmodule AllThingsSocialWeb.NicheLive.Index do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.Niches
  alias AllThingsSocial.Niches.Niche

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :niches, list_niches())}
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
