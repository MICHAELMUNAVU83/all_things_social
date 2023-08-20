defmodule AllThingsSocial.Repo.Migrations.CreateContentBoards do
  use Ecto.Migration

  def change do
    create table(:content_boards) do
      add :name, :string
      add :brand_id, references(:brands, on_delete: :delete_all)

      timestamps()
    end
  end
end
