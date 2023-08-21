defmodule AllThingsSocialWeb.RateLive.FormComponent do
  use AllThingsSocialWeb, :live_component

  alias AllThingsSocial.Rates

  @impl true
  def update(%{rate: rate} = assigns, socket) do
    changeset = Rates.change_rate(rate)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"rate" => rate_params}, socket) do
    changeset =
      socket.assigns.rate
      |> Rates.change_rate(rate_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"rate" => rate_params}, socket) do
    save_rate(socket, socket.assigns.action, rate_params)
  end

  defp save_rate(socket, :edit, rate_params) do
    case Rates.update_rate(socket.assigns.rate, rate_params) do
      {:ok, _rate} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rate updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_rate(socket, :add_rate, rate_params) do
    case Rates.create_rate(rate_params) do
      {:ok, _rate} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rate created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
