defmodule AllThingsSocial.Rates.Rate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rates" do
    field :description, :string
    field :platform, :string
    field :amount, :string
    belongs_to :influencer, AllThingsSocial.Influencers.Influencer

    timestamps()
  end

  @doc false
  def changeset(rate, attrs) do
    rate
    |> cast(attrs, [:platform, :description, :amount, :influencer_id])
    |> validate_required([:platform, :description, :amount, :influencer_id])
  end
end
