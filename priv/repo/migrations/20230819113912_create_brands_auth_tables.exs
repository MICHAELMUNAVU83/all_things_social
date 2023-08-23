defmodule AllThingsSocial.Repo.Migrations.CreateBrandsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:brands) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :username, :string, null: false
      add :phone_number, :string
      add :role, :string, null: false, default: "user"
      timestamps()
    end

    create unique_index(:brands, [:email])

    create table(:brands_tokens) do
      add :brand_id, references(:brands, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:brands_tokens, [:brand_id])
    create unique_index(:brands_tokens, [:context, :token])
  end
end
