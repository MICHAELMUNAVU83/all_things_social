defmodule AllThingsSocialWeb.InfluencerResetPasswordController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Influencers

  plug :get_influencer_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"influencer" => %{"email" => email}}) do
    if influencer = Influencers.get_influencer_by_email(email) do
      Influencers.deliver_influencer_reset_password_instructions(
        influencer,
        &Routes.influencer_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Influencers.change_influencer_password(conn.assigns.influencer))
  end

  # Do not log in the influencer after reset password to avoid a
  # leaked token giving the influencer access to the account.
  def update(conn, %{"influencer" => influencer_params}) do
    case Influencers.reset_influencer_password(conn.assigns.influencer, influencer_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.influencer_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_influencer_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if influencer = Influencers.get_influencer_by_reset_password_token(token) do
      conn |> assign(:influencer, influencer) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
