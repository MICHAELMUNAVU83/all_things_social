defmodule AllThingsSocial.Repo.Migrations.CreateContentBoards do
  use Ecto.Migration

  def change do
    create table(:content_boards) do
      add :name, :string

      timestamps()
    end
  end
end
