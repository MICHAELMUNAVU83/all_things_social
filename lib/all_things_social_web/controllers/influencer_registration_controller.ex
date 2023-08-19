defmodule AllThingsSocialWeb.InfluencerRegistrationController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Influencers
  alias AllThingsSocial.Influencers.Influencer
  alias AllThingsSocialWeb.InfluencerAuth

  def new(conn, _params) do
    changeset = Influencers.change_influencer_registration(%Influencer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"influencer" => influencer_params}) do
    case Influencers.register_influencer(influencer_params) do
      {:ok, influencer} ->
        {:ok, _} =
          Influencers.deliver_influencer_confirmation_instructions(
            influencer,
            &Routes.influencer_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Influencer created successfully.")
        |> InfluencerAuth.log_in_influencer(influencer)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
