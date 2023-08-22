defmodule AllThingsSocial.ContentBoards.ContentBoard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "content_boards" do
    field :name, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand
    has_many :tasks, AllThingsSocial.Tasks.Task
    has_many :payments, AllThingsSocial.Payments.Payment
    has_many :influencer_accounts, AllThingsSocial.InfluencerAccounts.InfluencerAccount
    has_many :chats, AllThingsSocial.Chats.Chat

    timestamps()
  end

  @doc false
  def changeset(content_board, attrs) do
    content_board
    |> cast(attrs, [:name, :brand_id])
    |> validate_required([:name, :brand_id])
  end
end
