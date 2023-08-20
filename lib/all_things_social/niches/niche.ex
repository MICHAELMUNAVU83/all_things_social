defmodule AllThingsSocial.Niches.Niche do
  use Ecto.Schema
  import Ecto.Changeset

  schema "niches" do
    field :name, :string
    belongs_to :influencer, AllThingsSocial.Influencers.Influencer

    timestamps()
  end

  @doc false
  def changeset(niche, attrs) do
    niche
    |> cast(attrs, [:name, :influencer_id])
    |> validate_required([:name, :influencer_id])
  end
end
