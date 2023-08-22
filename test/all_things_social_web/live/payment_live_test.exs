defmodule AllThingsSocialWeb.PaymentLiveTest do
  use AllThingsSocialWeb.ConnCase

  import Phoenix.LiveViewTest
  import AllThingsSocial.PaymentsFixtures

  @create_attrs %{status: "some status", price: "some price"}
  @update_attrs %{status: "some updated status", price: "some updated price"}
  @invalid_attrs %{status: nil, price: nil}

  defp create_payment(_) do
    payment = payment_fixture()
    %{payment: payment}
  end

  describe "Index" do
    setup [:create_payment]

    test "lists all payments", %{conn: conn, payment: payment} do
      {:ok, _index_live, html} = live(conn, Routes.payment_index_path(conn, :index))

      assert html =~ "Listing Payments"
      assert html =~ payment.status
    end

    test "saves new payment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.payment_index_path(conn, :index))

      assert index_live |> element("a", "New Payment") |> render_click() =~
               "New Payment"

      assert_patch(index_live, Routes.payment_index_path(conn, :new))

      assert index_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#payment-form", payment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.payment_index_path(conn, :index))

      assert html =~ "Payment created successfully"
      assert html =~ "some status"
    end

    test "updates payment in listing", %{conn: conn, payment: payment} do
      {:ok, index_live, _html} = live(conn, Routes.payment_index_path(conn, :index))

      assert index_live |> element("#payment-#{payment.id} a", "Edit") |> render_click() =~
               "Edit Payment"

      assert_patch(index_live, Routes.payment_index_path(conn, :edit, payment))

      assert index_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#payment-form", payment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.payment_index_path(conn, :index))

      assert html =~ "Payment updated successfully"
      assert html =~ "some updated status"
    end

    test "deletes payment in listing", %{conn: conn, payment: payment} do
      {:ok, index_live, _html} = live(conn, Routes.payment_index_path(conn, :index))

      assert index_live |> element("#payment-#{payment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#payment-#{payment.id}")
    end
  end

  describe "Show" do
    setup [:create_payment]

    test "displays payment", %{conn: conn, payment: payment} do
      {:ok, _show_live, html} = live(conn, Routes.payment_show_path(conn, :show, payment))

      assert html =~ "Show Payment"
      assert html =~ payment.status
    end

    test "updates payment within modal", %{conn: conn, payment: payment} do
      {:ok, show_live, _html} = live(conn, Routes.payment_show_path(conn, :show, payment))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Payment"

      assert_patch(show_live, Routes.payment_show_path(conn, :edit, payment))

      assert show_live
             |> form("#payment-form", payment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#payment-form", payment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.payment_show_path(conn, :show, payment))

      assert html =~ "Payment updated successfully"
      assert html =~ "some updated status"
    end
  end
end
