defmodule AllThingsSocialWeb.BrandSessionControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  import AllThingsSocial.BrandsFixtures

  setup do
    %{brand: brand_fixture()}
  end

  describe "GET /brands/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.brand_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, brand: brand} do
      conn = conn |> log_in_brand(brand) |> get(Routes.brand_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /brands/log_in" do
    test "logs the brand in", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_session_path(conn, :create), %{
          "brand" => %{"email" => brand.email, "password" => valid_brand_password()}
        })

      assert get_session(conn, :brand_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ brand.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the brand in with remember me", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_session_path(conn, :create), %{
          "brand" => %{
            "email" => brand.email,
            "password" => valid_brand_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_all_things_social_web_brand_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the brand in with return to", %{conn: conn, brand: brand} do
      conn =
        conn
        |> init_test_session(brand_return_to: "/foo/bar")
        |> post(Routes.brand_session_path(conn, :create), %{
          "brand" => %{
            "email" => brand.email,
            "password" => valid_brand_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_session_path(conn, :create), %{
          "brand" => %{"email" => brand.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /brands/log_out" do
    test "logs the brand out", %{conn: conn, brand: brand} do
      conn = conn |> log_in_brand(brand) |> delete(Routes.brand_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :brand_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the brand is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.brand_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :brand_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
