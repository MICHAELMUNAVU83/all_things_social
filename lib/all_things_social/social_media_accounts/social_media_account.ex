defmodule AllThingsSocial.SocialMediaAccounts.SocialMediaAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_media_accounts" do
    field :account_url, :string
    field :platform, :string

    timestamps()
  end

  @doc false
  def changeset(social_media_account, attrs) do
    social_media_account
    |> cast(attrs, [:account_url, :platform])
    |> validate_required([:account_url, :platform])
  end
end
