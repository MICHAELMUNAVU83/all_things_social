defmodule AllThingsSocial.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :status, :string, default: "pending"
    field :description, :string
    field :price, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand
    belongs_to :influencer, AllThingsSocial.InfluencerAccounts.InfluencerAccount
    belongs_to :content_board, AllThingsSocial.ContentBoards.ContentBoard

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :name,
      :description,
      :price,
      :status,
      :brand_id,
      :influencer_id,
      :content_board_id
    ])
    |> validate_required([
      :name,
      :description,
      :price,
      :status,
      :brand_id,
      :influencer_id,
      :content_board_id
    ])
  end
end
