defmodule AllThingsSocialWeb.InfluencerSettingsControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Influencers
  import AllThingsSocial.InfluencersFixtures

  setup :register_and_log_in_influencer

  describe "GET /influencers/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.influencer_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if influencer is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.influencer_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.influencer_session_path(conn, :new)
    end
  end

  describe "PUT /influencers/settings (change password form)" do
    test "updates the influencer password and resets tokens", %{
      conn: conn,
      influencer: influencer
    } do
      new_password_conn =
        put(conn, Routes.influencer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_influencer_password(),
          "influencer" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.influencer_settings_path(conn, :edit)

      assert get_session(new_password_conn, :influencer_token) !=
               get_session(conn, :influencer_token)

      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"

      assert Influencers.get_influencer_by_email_and_password(
               influencer.email,
               "new valid password"
             )
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.influencer_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "influencer" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :influencer_token) ==
               get_session(conn, :influencer_token)
    end
  end

  describe "PUT /influencers/settings (change email form)" do
    @tag :capture_log
    test "updates the influencer email", %{conn: conn, influencer: influencer} do
      conn =
        put(conn, Routes.influencer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_influencer_password(),
          "influencer" => %{"email" => unique_influencer_email()}
        })

      assert redirected_to(conn) == Routes.influencer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Influencers.get_influencer_by_email(influencer.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.influencer_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "influencer" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /influencers/settings/confirm_email/:token" do
    setup %{influencer: influencer} do
      email = unique_influencer_email()

      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_update_email_instructions(
            %{influencer | email: email},
            influencer.email,
            url
          )
        end)

      %{token: token, email: email}
    end

    test "updates the influencer email once", %{
      conn: conn,
      influencer: influencer,
      token: token,
      email: email
    } do
      conn = get(conn, Routes.influencer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.influencer_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Influencers.get_influencer_by_email(influencer.email)
      assert Influencers.get_influencer_by_email(email)

      conn = get(conn, Routes.influencer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.influencer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, influencer: influencer} do
      conn = get(conn, Routes.influencer_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.influencer_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Influencers.get_influencer_by_email(influencer.email)
    end

    test "redirects if influencer is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.influencer_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.influencer_session_path(conn, :new)
    end
  end
end
