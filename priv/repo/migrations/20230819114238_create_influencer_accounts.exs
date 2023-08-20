defmodule AllThingsSocial.Repo.Migrations.CreateInfluencerAccounts do
  use Ecto.Migration

  def change do
    create table(:influencer_accounts) do
      add :column, :string
      add :brand_id, references(:brands, on_delete: :nothing)
      add :influencer_id, references(:influencers, on_delete: :nothing)

      timestamps()
    end
  end
end
