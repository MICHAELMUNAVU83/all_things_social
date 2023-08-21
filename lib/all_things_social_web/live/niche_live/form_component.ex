defmodule AllThingsSocialWeb.NicheLive.FormComponent do
  use AllThingsSocialWeb, :live_component

  alias AllThingsSocial.Niches

  @impl true
  def update(%{niche: niche} = assigns, socket) do
    changeset = Niches.change_niche(niche)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"niche" => niche_params}, socket) do
    changeset =
      socket.assigns.niche
      |> Niches.change_niche(niche_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"niche" => niche_params}, socket) do
    save_niche(socket, socket.assigns.action, niche_params)
  end

  defp save_niche(socket, :edit_niche, niche_params) do
    case Niches.update_niche(socket.assigns.niche, niche_params) do
      {:ok, _niche} ->
        {:noreply,
         socket
         |> put_flash(:info, "Niche updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_niche(socket, :add_niche, niche_params) do
    case Niches.create_niche(niche_params) do
      {:ok, _niche} ->
        {:noreply,
         socket
         |> put_flash(:info, "Niche created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
