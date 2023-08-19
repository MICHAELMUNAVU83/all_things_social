defmodule AllThingsSocial.Repo.Migrations.CreateNiches do
  use Ecto.Migration

  def change do
    create table(:niches) do
      add :name, :string

      timestamps()
    end
  end
end
