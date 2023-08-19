defmodule AllThingsSocial.Repo.Migrations.CreateRates do
  use Ecto.Migration

  def change do
    create table(:rates) do
      add :platform, :string
      add :description, :string
      add :amount, :string

      timestamps()
    end
  end
end
