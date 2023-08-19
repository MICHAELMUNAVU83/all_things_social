defmodule AllThingsSocialWeb.InfluencerConfirmationControllerTest do
  use AllThingsSocialWeb.ConnCase, async: true

  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Repo
  import AllThingsSocial.InfluencersFixtures

  setup do
    %{influencer: influencer_fixture()}
  end

  describe "GET /influencers/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.influencer_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /influencers/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, influencer: influencer} do
      conn =
        post(conn, Routes.influencer_confirmation_path(conn, :create), %{
          "influencer" => %{"email" => influencer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Influencers.InfluencerToken, influencer_id: influencer.id).context == "confirm"
    end

    test "does not send confirmation token if Influencer is confirmed", %{conn: conn, influencer: influencer} do
      Repo.update!(Influencers.Influencer.confirm_changeset(influencer))

      conn =
        post(conn, Routes.influencer_confirmation_path(conn, :create), %{
          "influencer" => %{"email" => influencer.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Influencers.InfluencerToken, influencer_id: influencer.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.influencer_confirmation_path(conn, :create), %{
          "influencer" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Influencers.InfluencerToken) == []
    end
  end

  describe "GET /influencers/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.influencer_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.influencer_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /influencers/confirm/:token" do
    test "confirms the given token once", %{conn: conn, influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_confirmation_instructions(influencer, url)
        end)

      conn = post(conn, Routes.influencer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Influencer confirmed successfully"
      assert Influencers.get_influencer!(influencer.id).confirmed_at
      refute get_session(conn, :influencer_token)
      assert Repo.all(Influencers.InfluencerToken) == []

      # When not logged in
      conn = post(conn, Routes.influencer_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Influencer confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_influencer(influencer)
        |> post(Routes.influencer_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, influencer: influencer} do
      conn = post(conn, Routes.influencer_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Influencer confirmation link is invalid or it has expired"
      refute Influencers.get_influencer!(influencer.id).confirmed_at
    end
  end
end
