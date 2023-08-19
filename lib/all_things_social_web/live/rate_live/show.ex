defmodule AllThingsSocialWeb.RateLive.Show do
  use AllThingsSocialWeb, :live_view

  alias AllThingsSocial.Rates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:rate, Rates.get_rate!(id))}
  end

  defp page_title(:show), do: "Show Rate"
  defp page_title(:edit), do: "Edit Rate"
end
