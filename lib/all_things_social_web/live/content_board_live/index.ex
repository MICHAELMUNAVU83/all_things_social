defmodule AllThingsSocialWeb.ContentBoardLive.Index do
  use AllThingsSocialWeb, :brand_live_view

  alias AllThingsSocial.ContentBoards
  alias AllThingsSocial.ContentBoards.ContentBoard
  alias AllThingsSocial.Brands

  @impl true
  def mount(_params, session, socket) do
    logged_in_brand = Brands.get_brand_by_session_token(session["brand_token"])

    content_boards = ContentBoards.list_content_boards_for_a_brand(logged_in_brand.id)

    {:ok,
     socket
     |> assign(:logged_in_brand, logged_in_brand)
     |> assign(:content_boards, content_boards)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Content board")
    |> assign(:content_board, ContentBoards.get_content_board!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content board")
    |> assign(:content_board, %ContentBoard{})
  end

  defp apply_action(socket, :pay_premium, _params) do
    socket
    |> assign(:page_title, "New Content board")
    |> assign(:content_board, %ContentBoard{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content boards")
    |> assign(:content_board, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content_board = ContentBoards.get_content_board!(id)
    {:ok, _} = ContentBoards.delete_content_board(content_board)

    content_boards =
      ContentBoards.list_content_boards_for_a_brand(socket.assigns.logged_in_brand.id)

    {:noreply, assign(socket, :content_boards, content_boards)}
  end

  defp list_content_boards do
    ContentBoards.list_content_boards()
  end
end
