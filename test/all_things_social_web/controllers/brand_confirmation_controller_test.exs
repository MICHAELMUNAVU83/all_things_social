defmodule AllThingsSocialWeb.BrandConfirmationControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Brands
  alias AllThingsSocial.Repo
  import AllThingsSocial.BrandsFixtures

  setup do
    %{brand: brand_fixture()}
  end

  describe "GET /brands/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.brand_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /brands/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_confirmation_path(conn, :create), %{
          "brand" => %{"email" => brand.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Brands.BrandToken, brand_id: brand.id).context == "confirm"
    end

    test "does not send confirmation token if Brand is confirmed", %{conn: conn, brand: brand} do
      Repo.update!(Brands.Brand.confirm_changeset(brand))

      conn =
        post(conn, Routes.brand_confirmation_path(conn, :create), %{
          "brand" => %{"email" => brand.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Brands.BrandToken, brand_id: brand.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.brand_confirmation_path(conn, :create), %{
          "brand" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Brands.BrandToken) == []
    end
  end

  describe "GET /brands/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.brand_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.brand_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /brands/confirm/:token" do
    test "confirms the given token once", %{conn: conn, brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_confirmation_instructions(brand, url)
        end)

      conn = post(conn, Routes.brand_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Brand confirmed successfully"
      assert Brands.get_brand!(brand.id).confirmed_at
      refute get_session(conn, :brand_token)
      assert Repo.all(Brands.BrandToken) == []

      # When not logged in
      conn = post(conn, Routes.brand_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Brand confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_brand(brand)
        |> post(Routes.brand_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, brand: brand} do
      conn = post(conn, Routes.brand_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Brand confirmation link is invalid or it has expired"
      refute Brands.get_brand!(brand.id).confirmed_at
    end
  end
end
