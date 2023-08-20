defmodule AllThingsSocialWeb.SocialMediaAccountLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.SocialMediaAccountsFixtures

  @create_attrs %{account_url: "some account_url", platform: "some platform"}
  @update_attrs %{account_url: "some updated account_url", platform: "some updated platform"}
  @invalid_attrs %{account_url: nil, platform: nil}

  defp create_social_media_account(_) do
    social_media_account = social_media_account_fixture()
    %{social_media_account: social_media_account}
  end

  describe "Index" do
    setup [:create_social_media_account]

    test "lists all social_media_accounts", %{
      conn: conn,
      social_media_account: social_media_account
    } do
      {:ok, _index_live, html} = live(conn, Routes.social_media_account_index_path(conn, :index))

      assert html =~ "Listing Social media accounts"
      assert html =~ social_media_account.account_url
    end

    test "saves new social_media_account", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.social_media_account_index_path(conn, :index))

      assert index_live |> element("a", "New Social media account") |> render_click() =~
               "New Social media account"

      assert_patch(index_live, Routes.social_media_account_index_path(conn, :new))

      assert index_live
             |> form("#social_media_account-form", social_media_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#social_media_account-form", social_media_account: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.social_media_account_index_path(conn, :index))

      assert html =~ "Social media account created successfully"
      assert html =~ "some account_url"
    end

    test "updates social_media_account in listing", %{
      conn: conn,
      social_media_account: social_media_account
    } do
      {:ok, index_live, _html} = live(conn, Routes.social_media_account_index_path(conn, :index))

      assert index_live
             |> element("#social_media_account-#{social_media_account.id} a", "Edit")
             |> render_click() =~
               "Edit Social media account"

      assert_patch(
        index_live,
        Routes.social_media_account_index_path(conn, :edit, social_media_account)
      )

      assert index_live
             |> form("#social_media_account-form", social_media_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#social_media_account-form", social_media_account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.social_media_account_index_path(conn, :index))

      assert html =~ "Social media account updated successfully"
      assert html =~ "some updated account_url"
    end

    test "deletes social_media_account in listing", %{
      conn: conn,
      social_media_account: social_media_account
    } do
      {:ok, index_live, _html} = live(conn, Routes.social_media_account_index_path(conn, :index))

      assert index_live
             |> element("#social_media_account-#{social_media_account.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#social_media_account-#{social_media_account.id}")
    end
  end

  describe "Show" do
    setup [:create_social_media_account]

    test "displays social_media_account", %{
      conn: conn,
      social_media_account: social_media_account
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.social_media_account_show_path(conn, :show, social_media_account))

      assert html =~ "Show Social media account"
      assert html =~ social_media_account.account_url
    end

    test "updates social_media_account within modal", %{
      conn: conn,
      social_media_account: social_media_account
    } do
      {:ok, show_live, _html} =
        live(conn, Routes.social_media_account_show_path(conn, :show, social_media_account))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Social media account"

      assert_patch(
        show_live,
        Routes.social_media_account_show_path(conn, :edit, social_media_account)
      )

      assert show_live
             |> form("#social_media_account-form", social_media_account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#social_media_account-form", social_media_account: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.social_media_account_show_path(conn, :show, social_media_account)
        )

      assert html =~ "Social media account updated successfully"
      assert html =~ "some updated account_url"
    end
  end
end
