defmodule AllThingsSocial.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :status, :string
    field :price, :string
    belongs_to :brand, AllThingsSocial.Brands.Brand
    belongs_to :influencer, AllThingsSocial.Influencers.Influencer
    belongs_to :task, AllThingsSocial.Tasks.Task
    belongs_to :content_board, AllThingsSocial.ContentBoards.ContentBoard

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:price, :status, :brand_id, :influencer_id, :task_id, :content_board_id])
    |> validate_required([:price, :status, :brand_id, :influencer_id, :task_id, :content_board_id])
  end
end
