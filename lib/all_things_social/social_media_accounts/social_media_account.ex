defmodule AllThingsSocial.SocialMediaAccounts.SocialMediaAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_media_accounts" do
    field :account_url, :string
    field :platform, :string
    belongs_to :influencer, AllThingsSocial.Influencers.Influencer

    timestamps()
  end

  @doc false
  def changeset(social_media_account, attrs) do
    social_media_account
    |> cast(attrs, [:account_url, :platform, :influencer_id])
    |> validate_required([:account_url, :platform, :influencer_id])
    |> validate_format(:account_url, ~r/https:\/\//, message: "must start with 'https://'")
  end
end
