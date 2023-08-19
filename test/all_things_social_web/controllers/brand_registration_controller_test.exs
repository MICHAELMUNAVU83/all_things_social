defmodule AllThingsSocialWeb.BrandRegistrationControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  import AllThingsSocial.BrandsFixtures

  describe "GET /brands/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.brand_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_brand(brand_fixture()) |> get(Routes.brand_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /brands/register" do
    @tag :capture_log
    test "creates account and logs the brand in", %{conn: conn} do
      email = unique_brand_email()

      conn =
        post(conn, Routes.brand_registration_path(conn, :create), %{
          "brand" => valid_brand_attributes(email: email)
        })

      assert get_session(conn, :brand_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.brand_registration_path(conn, :create), %{
          "brand" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
