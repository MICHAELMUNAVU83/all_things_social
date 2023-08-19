defmodule AllThingsSocial.InfluencerAccounts.InfluencerAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "influencer_accounts" do
    field :column, :string

    timestamps()
  end

  @doc false
  def changeset(influencer_account, attrs) do
    influencer_account
    |> cast(attrs, [:column])
    |> validate_required([:column])
  end
end
