defmodule AllThingsSocial.ContentBoards.ContentBoard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "content_boards" do
    field :name, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand

    timestamps()
  end

  @doc false
  def changeset(content_board, attrs) do
    content_board
    |> cast(attrs, [:name, :brand_id])
    |> validate_required([:name, :brand_id])
  end
end
