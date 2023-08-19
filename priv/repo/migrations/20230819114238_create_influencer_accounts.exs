defmodule AllThingsSocial.Repo.Migrations.CreateInfluencerAccounts do
  use Ecto.Migration

  def change do
    create table(:influencer_accounts) do
      add :column, :string

      timestamps()
    end
  end
end
