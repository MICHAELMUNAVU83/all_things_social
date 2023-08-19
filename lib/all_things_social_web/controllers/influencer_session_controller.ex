defmodule AllThingsSocialWeb.InfluencerSessionController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Influencers
  alias AllThingsSocialWeb.InfluencerAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"influencer" => influencer_params}) do
    %{"email" => email, "password" => password} = influencer_params

    if influencer = Influencers.get_influencer_by_email_and_password(email, password) do
      InfluencerAuth.log_in_influencer(conn, influencer, influencer_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> InfluencerAuth.log_out_influencer()
  end
end
