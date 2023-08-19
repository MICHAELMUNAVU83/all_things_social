defmodule AllThingsSocial.Rates.Rate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rates" do
    field :description, :string
    field :platform, :string
    field :amount, :string

    timestamps()
  end

  @doc false
  def changeset(rate, attrs) do
    rate
    |> cast(attrs, [:platform, :description, :amount])
    |> validate_required([:platform, :description, :amount])
  end
end
