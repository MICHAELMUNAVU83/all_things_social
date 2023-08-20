defmodule AllThingsSocial.InfluencerAccounts.InfluencerAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "influencer_accounts" do
    field :column, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand
    belongs_to :influencer, AllThingsSocial.Influencers.Influencer
    belongs_to :content_board, AllThingsSocial.ContentBoards.ContentBoard

    timestamps()
  end

  @doc false
  def changeset(influencer_account, attrs) do
    influencer_account
    |> cast(attrs, [:column, :brand_id, :influencer_id, :content_board_id])
    |> validate_required([:column, :brand_id, :influencer_id, :content_board_id])
  end
end
