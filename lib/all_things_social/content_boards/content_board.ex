defmodule AllThingsSocial.ContentBoards.ContentBoard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "content_boards" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(content_board, attrs) do
    content_board
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
