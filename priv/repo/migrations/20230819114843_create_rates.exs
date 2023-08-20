defmodule AllThingsSocial.Repo.Migrations.CreateRates do
  use Ecto.Migration

  def change do
    create table(:rates) do
      add :platform, :string
      add :description, :string
      add :amount, :string
      add :influencer_id, references(:influencers, on_delete: :delete_all)

      timestamps()
    end
  end
end
