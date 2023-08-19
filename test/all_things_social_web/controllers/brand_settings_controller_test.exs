defmodule AllThingsSocialWeb.BrandSettingsControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Brands
  import AllThingsSocial.BrandsFixtures

  setup :register_and_log_in_brand

  describe "GET /brands/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.brand_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if brand is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.brand_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.brand_session_path(conn, :new)
    end
  end

  describe "PUT /brands/settings (change password form)" do
    test "updates the brand password and resets tokens", %{conn: conn, brand: brand} do
      new_password_conn =
        put(conn, Routes.brand_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_brand_password(),
          "brand" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.brand_settings_path(conn, :edit)
      assert get_session(new_password_conn, :brand_token) != get_session(conn, :brand_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Brands.get_brand_by_email_and_password(brand.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.brand_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "brand" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :brand_token) == get_session(conn, :brand_token)
    end
  end

  describe "PUT /brands/settings (change email form)" do
    @tag :capture_log
    test "updates the brand email", %{conn: conn, brand: brand} do
      conn =
        put(conn, Routes.brand_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_brand_password(),
          "brand" => %{"email" => unique_brand_email()}
        })

      assert redirected_to(conn) == Routes.brand_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Brands.get_brand_by_email(brand.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.brand_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "brand" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /brands/settings/confirm_email/:token" do
    setup %{brand: brand} do
      email = unique_brand_email()

      token =
        extract_brand_token(fn url ->
          Brands.deliver_update_email_instructions(%{brand | email: email}, brand.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the brand email once", %{conn: conn, brand: brand, token: token, email: email} do
      conn = get(conn, Routes.brand_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.brand_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Brands.get_brand_by_email(brand.email)
      assert Brands.get_brand_by_email(email)

      conn = get(conn, Routes.brand_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.brand_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, brand: brand} do
      conn = get(conn, Routes.brand_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.brand_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Brands.get_brand_by_email(brand.email)
    end

    test "redirects if brand is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.brand_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.brand_session_path(conn, :new)
    end
  end
end
