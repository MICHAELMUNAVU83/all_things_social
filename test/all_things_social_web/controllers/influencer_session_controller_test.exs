defmodule AllThingsSocialWeb.InfluencerSessionControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  import AllThingsSocial.InfluencersFixtures

  setup do
    %{influencer: influencer_fixture()}
  end

  describe "GET /influencers/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.influencer_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, influencer: influencer} do
      conn = conn |> log_in_influencer(influencer) |> get(Routes.influencer_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /influencers/log_in" do
    test "logs the influencer in", %{conn: conn, influencer: influencer} do
      conn =
        post(conn, Routes.influencer_session_path(conn, :create), %{
          "influencer" => %{"email" => influencer.email, "password" => valid_influencer_password()}
        })

      assert get_session(conn, :influencer_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ influencer.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the influencer in with remember me", %{conn: conn, influencer: influencer} do
      conn =
        post(conn, Routes.influencer_session_path(conn, :create), %{
          "influencer" => %{
            "email" => influencer.email,
            "password" => valid_influencer_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_all_things_social_web_influencer_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the influencer in with return to", %{conn: conn, influencer: influencer} do
      conn =
        conn
        |> init_test_session(influencer_return_to: "/foo/bar")
        |> post(Routes.influencer_session_path(conn, :create), %{
          "influencer" => %{
            "email" => influencer.email,
            "password" => valid_influencer_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, influencer: influencer} do
      conn =
        post(conn, Routes.influencer_session_path(conn, :create), %{
          "influencer" => %{"email" => influencer.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /influencers/log_out" do
    test "logs the influencer out", %{conn: conn, influencer: influencer} do
      conn = conn |> log_in_influencer(influencer) |> delete(Routes.influencer_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :influencer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the influencer is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.influencer_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :influencer_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
