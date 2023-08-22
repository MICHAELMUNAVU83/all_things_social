defmodule AllThingsSocial.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :price, :string
      add :status, :string
      add :brand_id, references(:brands, on_delete: :nothing)
      add :influencer_id, references(:influencers, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)
      add :content_board_id, references(:content_boards, on_delete: :nothing)

      timestamps()
    end
  end
end
