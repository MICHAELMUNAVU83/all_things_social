defmodule AllThingsSocialWeb.SocialMediaAccountLive.FormComponent do
  use AllThingsSocialWeb, :live_component

  alias AllThingsSocial.SocialMediaAccounts

  @impl true
  def update(%{social_media_account: social_media_account} = assigns, socket) do
    changeset = SocialMediaAccounts.change_social_media_account(social_media_account)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"social_media_account" => social_media_account_params}, socket) do
    changeset =
      socket.assigns.social_media_account
      |> SocialMediaAccounts.change_social_media_account(social_media_account_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"social_media_account" => social_media_account_params}, socket) do
    save_social_media_account(socket, socket.assigns.action, social_media_account_params)
  end

  defp save_social_media_account(socket, :edit, social_media_account_params) do
    case SocialMediaAccounts.update_social_media_account(socket.assigns.social_media_account, social_media_account_params) do
      {:ok, _social_media_account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Social media account updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_social_media_account(socket, :new, social_media_account_params) do
    case SocialMediaAccounts.create_social_media_account(social_media_account_params) do
      {:ok, _social_media_account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Social media account created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
