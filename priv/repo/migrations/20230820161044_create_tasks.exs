defmodule AllThingsSocial.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :description, :string
      add :price, :string
      add :status, :string, default: "pending"
      add :brand_id, references(:brands, on_delete: :nothing)
      add :influencer_id, references(:influencer_accounts, on_delete: :nothing)
      add :content_board_id, references(:content_boards, on_delete: :nothing)

      timestamps()
    end
  end
end
