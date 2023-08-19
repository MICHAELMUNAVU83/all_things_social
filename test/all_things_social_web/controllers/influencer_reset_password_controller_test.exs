defmodule AllThingsSocialWeb.InfluencerResetPasswordControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Repo
  import AllThingsSocial.InfluencersFixtures

  setup do
    %{influencer: influencer_fixture()}
  end

  describe "GET /influencers/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.influencer_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /influencers/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, influencer: influencer} do
      conn =
        post(conn, Routes.influencer_reset_password_path(conn, :create), %{
          "influencer" => %{"email" => influencer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Influencers.InfluencerToken, influencer_id: influencer.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.influencer_reset_password_path(conn, :create), %{
          "influencer" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Influencers.InfluencerToken) == []
    end
  end

  describe "GET /influencers/reset_password/:token" do
    setup %{influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_reset_password_instructions(influencer, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.influencer_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.influencer_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /influencers/reset_password/:token" do
    setup %{influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_reset_password_instructions(influencer, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, influencer: influencer, token: token} do
      conn =
        put(conn, Routes.influencer_reset_password_path(conn, :update, token), %{
          "influencer" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.influencer_session_path(conn, :new)
      refute get_session(conn, :influencer_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Influencers.get_influencer_by_email_and_password(influencer.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.influencer_reset_password_path(conn, :update, token), %{
          "influencer" => %{
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
      conn = put(conn, Routes.influencer_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
