defmodule AllThingsSocial.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :message, :string
    field :sender, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand
    belongs_to :influencer, AllThingsSocial.InfluencerAccounts.InfluencerAccount
    belongs_to :content_board, AllThingsSocial.ContentBoards.ContentBoard

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:message, :brand_id, :influencer_id, :content_board_id, :sender])
    |> validate_required([:message, :brand_id, :influencer_id, :content_board_id, :sender])
  end
end
