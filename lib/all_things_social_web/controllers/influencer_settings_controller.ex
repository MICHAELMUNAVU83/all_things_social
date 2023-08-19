defmodule AllThingsSocialWeb.InfluencerSettingsController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Influencers
  alias AllThingsSocialWeb.InfluencerAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "influencer" => influencer_params} = params
    influencer = conn.assigns.current_influencer

    case Influencers.apply_influencer_email(influencer, password, influencer_params) do
      {:ok, applied_influencer} ->
        Influencers.deliver_update_email_instructions(
          applied_influencer,
          influencer.email,
          &Routes.influencer_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.influencer_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "influencer" => influencer_params} = params
    influencer = conn.assigns.current_influencer

    case Influencers.update_influencer_password(influencer, password, influencer_params) do
      {:ok, influencer} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:influencer_return_to, Routes.influencer_settings_path(conn, :edit))
        |> InfluencerAuth.log_in_influencer(influencer)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Influencers.update_influencer_email(conn.assigns.current_influencer, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.influencer_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.influencer_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    influencer = conn.assigns.current_influencer

    conn
    |> assign(:email_changeset, Influencers.change_influencer_email(influencer))
    |> assign(:password_changeset, Influencers.change_influencer_password(influencer))
  end
end
