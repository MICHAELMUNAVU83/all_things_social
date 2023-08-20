defmodule AllThingsSocial.Repo.Migrations.CreateSocialMediaAccounts do
  use Ecto.Migration

  def change do
    create table(:social_media_accounts) do
      add :account_url, :string
      add :platform, :string
      add :influencer_id, references(:influencers, on_delete: :delete_all)
      add :content_board_id, references(:content_boards, on_delete: :delete_all)
      timestamps()
    end
  end
end
