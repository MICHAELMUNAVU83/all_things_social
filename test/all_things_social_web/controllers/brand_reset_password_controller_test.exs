defmodule AllThingsSocialWeb.BrandResetPasswordControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Brands
  alias AllThingsSocial.Repo
  import AllThingsSocial.BrandsFixtures

  setup do
    %{brand: brand_fixture()}
  end

  describe "GET /brands/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.brand_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /brands/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_reset_password_path(conn, :create), %{
          "brand" => %{"email" => brand.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Brands.BrandToken, brand_id: brand.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.brand_reset_password_path(conn, :create), %{
          "brand" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Brands.BrandToken) == []
    end
  end

  describe "GET /brands/reset_password/:token" do
    setup %{brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_reset_password_instructions(brand, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.brand_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.brand_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /brands/reset_password/:token" do
    setup %{brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_reset_password_instructions(brand, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, brand: brand, token: token} do
      conn =
        put(conn, Routes.brand_reset_password_path(conn, :update, token), %{
          "brand" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.brand_session_path(conn, :new)
      refute get_session(conn, :brand_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Brands.get_brand_by_email_and_password(brand.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.brand_reset_password_path(conn, :update, token), %{
          "brand" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.brand_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
