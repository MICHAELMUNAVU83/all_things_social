defmodule AllThingsSocialWeb.ContentBoardLive.FormComponent do
  use AllThingsSocialWeb, :live_component

  alias AllThingsSocial.ContentBoards

  @impl true
  def update(%{content_board: content_board} = assigns, socket) do
    changeset = ContentBoards.change_content_board(content_board)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"content_board" => content_board_params}, socket) do
    changeset =
      socket.assigns.content_board
      |> ContentBoards.change_content_board(content_board_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"content_board" => content_board_params}, socket) do
    save_content_board(socket, socket.assigns.action, content_board_params)
  end

  defp save_content_board(socket, :edit, content_board_params) do
    case ContentBoards.update_content_board(socket.assigns.content_board, content_board_params) do
      {:ok, _content_board} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content board updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_content_board(socket, :new, content_board_params) do
    case ContentBoards.create_content_board(content_board_params) do
      {:ok, _content_board} ->
        {:noreply,
         socket
         |> put_flash(:info, "Content board created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
