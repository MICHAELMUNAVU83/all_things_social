defmodule AllThingsSocial.Repo.Migrations.CreateInfluencersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:influencers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :username, :string, null: false
      add :phone_number, :string
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:influencers, [:email])

    create table(:influencers_tokens) do
      add :influencer_id, references(:influencers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:influencers_tokens, [:influencer_id])
    create unique_index(:influencers_tokens, [:context, :token])
  end
end
