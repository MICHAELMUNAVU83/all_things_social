defmodule AllThingsSocialWeb.InfluencerAccountLive.FormComponent do
  use AllThingsSocialWeb, :live_component

  alias AllThingsSocial.InfluencerAccounts

  @impl true
  def update(%{influencer_account: influencer_account} = assigns, socket) do
    changeset = InfluencerAccounts.change_influencer_account(influencer_account)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"influencer_account" => influencer_account_params}, socket) do
    changeset =
      socket.assigns.influencer_account
      |> InfluencerAccounts.change_influencer_account(influencer_account_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"influencer_account" => influencer_account_params}, socket) do
    save_influencer_account(socket, socket.assigns.action, influencer_account_params)
  end

  defp save_influencer_account(socket, :edit, influencer_account_params) do
    case InfluencerAccounts.update_influencer_account(socket.assigns.influencer_account, influencer_account_params) do
      {:ok, _influencer_account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Influencer account updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_influencer_account(socket, :new, influencer_account_params) do
    case InfluencerAccounts.create_influencer_account(influencer_account_params) do
      {:ok, _influencer_account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Influencer account created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
