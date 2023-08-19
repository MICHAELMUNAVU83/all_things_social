defmodule AllThingsSocialWeb.NicheLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.NichesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_niche(_) do
    niche = niche_fixture()
    %{niche: niche}
  end

  describe "Index" do
    setup [:create_niche]

    test "lists all niches", %{conn: conn, niche: niche} do
      {:ok, _index_live, html} = live(conn, Routes.niche_index_path(conn, :index))

      assert html =~ "Listing Niches"
      assert html =~ niche.name
    end

    test "saves new niche", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.niche_index_path(conn, :index))

      assert index_live |> element("a", "New Niche") |> render_click() =~
               "New Niche"

      assert_patch(index_live, Routes.niche_index_path(conn, :new))

      assert index_live
             |> form("#niche-form", niche: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#niche-form", niche: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.niche_index_path(conn, :index))

      assert html =~ "Niche created successfully"
      assert html =~ "some name"
    end

    test "updates niche in listing", %{conn: conn, niche: niche} do
      {:ok, index_live, _html} = live(conn, Routes.niche_index_path(conn, :index))

      assert index_live |> element("#niche-#{niche.id} a", "Edit") |> render_click() =~
               "Edit Niche"

      assert_patch(index_live, Routes.niche_index_path(conn, :edit, niche))

      assert index_live
             |> form("#niche-form", niche: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#niche-form", niche: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.niche_index_path(conn, :index))

      assert html =~ "Niche updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes niche in listing", %{conn: conn, niche: niche} do
      {:ok, index_live, _html} = live(conn, Routes.niche_index_path(conn, :index))

      assert index_live |> element("#niche-#{niche.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#niche-#{niche.id}")
    end
  end

  describe "Show" do
    setup [:create_niche]

    test "displays niche", %{conn: conn, niche: niche} do
      {:ok, _show_live, html} = live(conn, Routes.niche_show_path(conn, :show, niche))

      assert html =~ "Show Niche"
      assert html =~ niche.name
    end

    test "updates niche within modal", %{conn: conn, niche: niche} do
      {:ok, show_live, _html} = live(conn, Routes.niche_show_path(conn, :show, niche))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Niche"

      assert_patch(show_live, Routes.niche_show_path(conn, :edit, niche))

      assert show_live
             |> form("#niche-form", niche: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#niche-form", niche: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.niche_show_path(conn, :show, niche))

      assert html =~ "Niche updated successfully"
      assert html =~ "some updated name"
    end
  end
end
