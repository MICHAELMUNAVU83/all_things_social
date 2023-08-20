defmodule AllThingsSocial.Repo.Migrations.CreateNiches do
  use Ecto.Migration

  def change do
    create table(:niches) do
      add :name, :string
      add :influencer_id, references(:influencers, on_delete: :delete_all)

      timestamps()
    end
  end
end
