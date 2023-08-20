defmodule AllThingsSocialWeb.InfluencerAccountLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.InfluencerAccountsFixtures

  @create_attrs %{column: "some column"}
  @update_attrs %{column: "some updated column"}
  @invalid_attrs %{column: nil}

  defp create_influencer_account(_) do
    influencer_account = influencer_account_fixture()
    %{influencer_account: influencer_account}
  end

  describe "Index" do
    setup [:create_influencer_account]

    test "lists all influencer_accounts", %{conn: conn, influencer_account: influencer_account} do
      {:ok, _index_live, html} = live(conn, Routes.influencer_account_index_path(conn, :index))

      assert html =~ "Listing Influencer accounts"
      assert html =~ influencer_account.column
    end

    test "saves new influencer_account", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.influencer_account_index_path(conn, :index))

      assert index_live |> element("a", "New Influencer account") |> render_click() =~
               "New Influencer account"

      assert_patch(index_live, Routes.influencer_account_index_path(conn, :new))

      assert index_live
             |> form("#influencer_account-form", influencer_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#influencer_account-form", influencer_account: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.influencer_account_index_path(conn, :index))

      assert html =~ "Influencer account created successfully"
      assert html =~ "some column"
    end

    test "updates influencer_account in listing", %{
      conn: conn,
      influencer_account: influencer_account
    } do
      {:ok, index_live, _html} = live(conn, Routes.influencer_account_index_path(conn, :index))

      assert index_live
             |> element("#influencer_account-#{influencer_account.id} a", "Edit")
             |> render_click() =~
               "Edit Influencer account"

      assert_patch(
        index_live,
        Routes.influencer_account_index_path(conn, :edit, influencer_account)
      )

      assert index_live
             |> form("#influencer_account-form", influencer_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#influencer_account-form", influencer_account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.influencer_account_index_path(conn, :index))

      assert html =~ "Influencer account updated successfully"
      assert html =~ "some updated column"
    end

    test "deletes influencer_account in listing", %{
      conn: conn,
      influencer_account: influencer_account
    } do
      {:ok, index_live, _html} = live(conn, Routes.influencer_account_index_path(conn, :index))

      assert index_live
             |> element("#influencer_account-#{influencer_account.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#influencer_account-#{influencer_account.id}")
    end
  end

  describe "Show" do
    setup [:create_influencer_account]

    test "displays influencer_account", %{conn: conn, influencer_account: influencer_account} do
      {:ok, _show_live, html} =
        live(conn, Routes.influencer_account_show_path(conn, :show, influencer_account))

      assert html =~ "Show Influencer account"
      assert html =~ influencer_account.column
    end

    test "updates influencer_account within modal", %{
      conn: conn,
      influencer_account: influencer_account
    } do
      {:ok, show_live, _html} =
        live(conn, Routes.influencer_account_show_path(conn, :show, influencer_account))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Influencer account"

      assert_patch(
        show_live,
        Routes.influencer_account_show_path(conn, :edit, influencer_account)
      )

      assert show_live
             |> form("#influencer_account-form", influencer_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#influencer_account-form", influencer_account: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.influencer_account_show_path(conn, :show, influencer_account)
        )

      assert html =~ "Influencer account updated successfully"
      assert html =~ "some updated column"
    end
  end
end
