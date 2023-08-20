defmodule AllThingsSocialWeb.InfluencerAuthTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Influencers
  alias AllThingsSocialWeb.InfluencerAuth
  import AllThingsSocial.InfluencersFixtures

  @remember_me_cookie "_all_things_social_web_influencer_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AllThingsSocialWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{influencer: influencer_fixture(), conn: conn}
  end

  describe "log_in_influencer/3" do
    test "stores the influencer token in the session", %{conn: conn, influencer: influencer} do
      conn = InfluencerAuth.log_in_influencer(conn, influencer)
      assert token = get_session(conn, :influencer_token)

      assert get_session(conn, :live_socket_id) ==
               "influencers_sessions:#{Base.url_encode64(token)}"

      assert redirected_to(conn) == "/"
      assert Influencers.get_influencer_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{
      conn: conn,
      influencer: influencer
    } do
      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> InfluencerAuth.log_in_influencer(influencer)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, influencer: influencer} do
      conn =
        conn
        |> put_session(:influencer_return_to, "/hello")
        |> InfluencerAuth.log_in_influencer(influencer)

      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, influencer: influencer} do
      conn =
        conn
        |> fetch_cookies()
        |> InfluencerAuth.log_in_influencer(influencer, %{"remember_me" => "true"})

      assert get_session(conn, :influencer_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :influencer_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_influencer/1" do
    test "erases session and cookies", %{conn: conn, influencer: influencer} do
      influencer_token = Influencers.generate_influencer_session_token(influencer)

      conn =
        conn
        |> put_session(:influencer_token, influencer_token)
        |> put_req_cookie(@remember_me_cookie, influencer_token)
        |> fetch_cookies()
        |> InfluencerAuth.log_out_influencer()

      refute get_session(conn, :influencer_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Influencers.get_influencer_by_session_token(influencer_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "influencers_sessions:abcdef-token"
      AllThingsSocialWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> InfluencerAuth.log_out_influencer()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if influencer is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> InfluencerAuth.log_out_influencer()
      refute get_session(conn, :influencer_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_influencer/2" do
    test "authenticates influencer from session", %{conn: conn, influencer: influencer} do
      influencer_token = Influencers.generate_influencer_session_token(influencer)

      conn =
        conn
        |> put_session(:influencer_token, influencer_token)
        |> InfluencerAuth.fetch_current_influencer([])

      assert conn.assigns.current_influencer.id == influencer.id
    end

    test "authenticates influencer from cookies", %{conn: conn, influencer: influencer} do
      logged_in_conn =
        conn
        |> fetch_cookies()
        |> InfluencerAuth.log_in_influencer(influencer, %{"remember_me" => "true"})

      influencer_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> InfluencerAuth.fetch_current_influencer([])

      assert get_session(conn, :influencer_token) == influencer_token
      assert conn.assigns.current_influencer.id == influencer.id
    end

    test "does not authenticate if data is missing", %{conn: conn, influencer: influencer} do
      _ = Influencers.generate_influencer_session_token(influencer)
      conn = InfluencerAuth.fetch_current_influencer(conn, [])
      refute get_session(conn, :influencer_token)
      refute conn.assigns.current_influencer
    end
  end

  describe "redirect_if_influencer_is_authenticated/2" do
    test "redirects if influencer is authenticated", %{conn: conn, influencer: influencer} do
      conn =
        conn
        |> assign(:current_influencer, influencer)
        |> InfluencerAuth.redirect_if_influencer_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if influencer is not authenticated", %{conn: conn} do
      conn = InfluencerAuth.redirect_if_influencer_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_influencer/2" do
    test "redirects if influencer is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> InfluencerAuth.require_authenticated_influencer([])
      assert conn.halted
      assert redirected_to(conn) == Routes.influencer_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> InfluencerAuth.require_authenticated_influencer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :influencer_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> InfluencerAuth.require_authenticated_influencer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :influencer_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> InfluencerAuth.require_authenticated_influencer([])

      assert halted_conn.halted
      refute get_session(halted_conn, :influencer_return_to)
    end

    test "does not redirect if influencer is authenticated", %{conn: conn, influencer: influencer} do
      conn =
        conn
        |> assign(:current_influencer, influencer)
        |> InfluencerAuth.require_authenticated_influencer([])

      refute conn.halted
      refute conn.status
    end
  end
end
