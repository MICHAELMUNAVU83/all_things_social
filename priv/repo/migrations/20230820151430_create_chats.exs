defmodule AllThingsSocial.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :message, :string
      add :brand_id, references(:brands, on_delete: :nothing)
      add :influencer_id, references(:influencer_accounts, on_delete: :nothing)
      add :content_board_id, references(:content_boards, on_delete: :nothing)
      add :sender_id, :integer

      timestamps()
    end
  end
end
