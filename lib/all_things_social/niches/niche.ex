defmodule AllThingsSocial.Niches.Niche do
  use Ecto.Schema
  import Ecto.Changeset

  schema "niches" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(niche, attrs) do
    niche
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
