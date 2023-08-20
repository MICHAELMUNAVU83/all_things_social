defmodule AllThingsSocialWeb.RateLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.RatesFixtures

  @create_attrs %{
    description: "some description",
    platform: "some platform",
    amount: "some amount"
  }
  @update_attrs %{
    description: "some updated description",
    platform: "some updated platform",
    amount: "some updated amount"
  }
  @invalid_attrs %{description: nil, platform: nil, amount: nil}

  defp create_rate(_) do
    rate = rate_fixture()
    %{rate: rate}
  end

  describe "Index" do
    setup [:create_rate]

    test "lists all rates", %{conn: conn, rate: rate} do
      {:ok, _index_live, html} = live(conn, Routes.rate_index_path(conn, :index))

      assert html =~ "Listing Rates"
      assert html =~ rate.description
    end

    test "saves new rate", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.rate_index_path(conn, :index))

      assert index_live |> element("a", "New Rate") |> render_click() =~
               "New Rate"

      assert_patch(index_live, Routes.rate_index_path(conn, :new))

      assert index_live
             |> form("#rate-form", rate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#rate-form", rate: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.rate_index_path(conn, :index))

      assert html =~ "Rate created successfully"
      assert html =~ "some description"
    end

    test "updates rate in listing", %{conn: conn, rate: rate} do
      {:ok, index_live, _html} = live(conn, Routes.rate_index_path(conn, :index))

      assert index_live |> element("#rate-#{rate.id} a", "Edit") |> render_click() =~
               "Edit Rate"

      assert_patch(index_live, Routes.rate_index_path(conn, :edit, rate))

      assert index_live
             |> form("#rate-form", rate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#rate-form", rate: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.rate_index_path(conn, :index))

      assert html =~ "Rate updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes rate in listing", %{conn: conn, rate: rate} do
      {:ok, index_live, _html} = live(conn, Routes.rate_index_path(conn, :index))

      assert index_live |> element("#rate-#{rate.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rate-#{rate.id}")
    end
  end

  describe "Show" do
    setup [:create_rate]

    test "displays rate", %{conn: conn, rate: rate} do
      {:ok, _show_live, html} = live(conn, Routes.rate_show_path(conn, :show, rate))

      assert html =~ "Show Rate"
      assert html =~ rate.description
    end

    test "updates rate within modal", %{conn: conn, rate: rate} do
      {:ok, show_live, _html} = live(conn, Routes.rate_show_path(conn, :show, rate))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rate"

      assert_patch(show_live, Routes.rate_show_path(conn, :edit, rate))

      assert show_live
             |> form("#rate-form", rate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#rate-form", rate: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.rate_show_path(conn, :show, rate))

      assert html =~ "Rate updated successfully"
      assert html =~ "some updated description"
    end
  end
end
