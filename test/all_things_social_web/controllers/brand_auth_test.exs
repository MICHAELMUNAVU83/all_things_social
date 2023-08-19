defmodule AllThingsSocialWeb.BrandAuthTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Brands
  alias AllThingsSocialWeb.BrandAuth
  import AllThingsSocial.BrandsFixtures

  @remember_me_cookie "_all_things_social_web_brand_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AllThingsSocialWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{brand: brand_fixture(), conn: conn}
  end

  describe "log_in_brand/3" do
    test "stores the brand token in the session", %{conn: conn, brand: brand} do
      conn = BrandAuth.log_in_brand(conn, brand)
      assert token = get_session(conn, :brand_token)
      assert get_session(conn, :live_socket_id) == "brands_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Brands.get_brand_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, brand: brand} do
      conn = conn |> put_session(:to_be_removed, "value") |> BrandAuth.log_in_brand(brand)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, brand: brand} do
      conn = conn |> put_session(:brand_return_to, "/hello") |> BrandAuth.log_in_brand(brand)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, brand: brand} do
      conn = conn |> fetch_cookies() |> BrandAuth.log_in_brand(brand, %{"remember_me" => "true"})
      assert get_session(conn, :brand_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :brand_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_brand/1" do
    test "erases session and cookies", %{conn: conn, brand: brand} do
      brand_token = Brands.generate_brand_session_token(brand)

      conn =
        conn
        |> put_session(:brand_token, brand_token)
        |> put_req_cookie(@remember_me_cookie, brand_token)
        |> fetch_cookies()
        |> BrandAuth.log_out_brand()

      refute get_session(conn, :brand_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Brands.get_brand_by_session_token(brand_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "brands_sessions:abcdef-token"
      AllThingsSocialWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> BrandAuth.log_out_brand()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if brand is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> BrandAuth.log_out_brand()
      refute get_session(conn, :brand_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_brand/2" do
    test "authenticates brand from session", %{conn: conn, brand: brand} do
      brand_token = Brands.generate_brand_session_token(brand)
      conn = conn |> put_session(:brand_token, brand_token) |> BrandAuth.fetch_current_brand([])
      assert conn.assigns.current_brand.id == brand.id
    end

    test "authenticates brand from cookies", %{conn: conn, brand: brand} do
      logged_in_conn =
        conn |> fetch_cookies() |> BrandAuth.log_in_brand(brand, %{"remember_me" => "true"})

      brand_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> BrandAuth.fetch_current_brand([])

      assert get_session(conn, :brand_token) == brand_token
      assert conn.assigns.current_brand.id == brand.id
    end

    test "does not authenticate if data is missing", %{conn: conn, brand: brand} do
      _ = Brands.generate_brand_session_token(brand)
      conn = BrandAuth.fetch_current_brand(conn, [])
      refute get_session(conn, :brand_token)
      refute conn.assigns.current_brand
    end
  end

  describe "redirect_if_brand_is_authenticated/2" do
    test "redirects if brand is authenticated", %{conn: conn, brand: brand} do
      conn = conn |> assign(:current_brand, brand) |> BrandAuth.redirect_if_brand_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if brand is not authenticated", %{conn: conn} do
      conn = BrandAuth.redirect_if_brand_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_brand/2" do
    test "redirects if brand is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> BrandAuth.require_authenticated_brand([])
      assert conn.halted
      assert redirected_to(conn) == Routes.brand_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> BrandAuth.require_authenticated_brand([])

      assert halted_conn.halted
      assert get_session(halted_conn, :brand_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> BrandAuth.require_authenticated_brand([])

      assert halted_conn.halted
      assert get_session(halted_conn, :brand_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> BrandAuth.require_authenticated_brand([])

      assert halted_conn.halted
      refute get_session(halted_conn, :brand_return_to)
    end

    test "does not redirect if brand is authenticated", %{conn: conn, brand: brand} do
      conn = conn |> assign(:current_brand, brand) |> BrandAuth.require_authenticated_brand([])
      refute conn.halted
      refute conn.status
    end
  end
end
