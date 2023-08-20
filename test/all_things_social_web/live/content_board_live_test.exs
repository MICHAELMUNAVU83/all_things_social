defmodule AllThingsSocialWeb.ContentBoardLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.ContentBoardsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_content_board(_) do
    content_board = content_board_fixture()
    %{content_board: content_board}
  end

  describe "Index" do
    setup [:create_content_board]

    test "lists all content_boards", %{conn: conn, content_board: content_board} do
      {:ok, _index_live, html} = live(conn, Routes.content_board_index_path(conn, :index))

      assert html =~ "Listing Content boards"
      assert html =~ content_board.name
    end

    test "saves new content_board", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.content_board_index_path(conn, :index))

      assert index_live |> element("a", "New Content board") |> render_click() =~
               "New Content board"

      assert_patch(index_live, Routes.content_board_index_path(conn, :new))

      assert index_live
             |> form("#content_board-form", content_board: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content_board-form", content_board: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_board_index_path(conn, :index))

      assert html =~ "Content board created successfully"
      assert html =~ "some name"
    end

    test "updates content_board in listing", %{conn: conn, content_board: content_board} do
      {:ok, index_live, _html} = live(conn, Routes.content_board_index_path(conn, :index))

      assert index_live
             |> element("#content_board-#{content_board.id} a", "Edit")
             |> render_click() =~
               "Edit Content board"

      assert_patch(index_live, Routes.content_board_index_path(conn, :edit, content_board))

      assert index_live
             |> form("#content_board-form", content_board: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#content_board-form", content_board: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_board_index_path(conn, :index))

      assert html =~ "Content board updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes content_board in listing", %{conn: conn, content_board: content_board} do
      {:ok, index_live, _html} = live(conn, Routes.content_board_index_path(conn, :index))

      assert index_live
             |> element("#content_board-#{content_board.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#content_board-#{content_board.id}")
    end
  end

  describe "Show" do
    setup [:create_content_board]

    test "displays content_board", %{conn: conn, content_board: content_board} do
      {:ok, _show_live, html} =
        live(conn, Routes.content_board_show_path(conn, :show, content_board))

      assert html =~ "Show Content board"
      assert html =~ content_board.name
    end

    test "updates content_board within modal", %{conn: conn, content_board: content_board} do
      {:ok, show_live, _html} =
        live(conn, Routes.content_board_show_path(conn, :show, content_board))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Content board"

      assert_patch(show_live, Routes.content_board_show_path(conn, :edit, content_board))

      assert show_live
             |> form("#content_board-form", content_board: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#content_board-form", content_board: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.content_board_show_path(conn, :show, content_board))

      assert html =~ "Content board updated successfully"
      assert html =~ "some updated name"
    end
  end
end
