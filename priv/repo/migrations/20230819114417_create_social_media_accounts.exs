defmodule AllThingsSocial.Repo.Migrations.CreateSocialMediaAccounts do
  use Ecto.Migration

  def change do
    create table(:social_media_accounts) do
      add :account_url, :string
      add :platform, :string

      timestamps()
    end
  end
end
