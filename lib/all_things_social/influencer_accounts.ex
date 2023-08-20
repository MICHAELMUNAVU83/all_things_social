defmodule AllThingsSocial.InfluencerAccounts do
  @moduledoc """
  The InfluencerAccounts context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.InfluencerAccounts.InfluencerAccount

  @doc """
  Returns the list of influencer_accounts.

  ## Examples

      iex> list_influencer_accounts()
      [%InfluencerAccount{}, ...]

  """
  def list_influencer_accounts do
    Repo.all(InfluencerAccount)
  end

  def list_influencer_accounts_for_a_brand(brand_id) do
    from(i in InfluencerAccount, where: i.brand_id == ^brand_id) |> Repo.all()
  end

  @doc """
  Gets a single influencer_account.

  Raises `Ecto.NoResultsError` if the Influencer account does not exist.

  ## Examples

      iex> get_influencer_account!(123)
      %InfluencerAccount{}

      iex> get_influencer_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_influencer_account!(id), do: Repo.get!(InfluencerAccount, id)

  @doc """
  Creates a influencer_account.

  ## Examples

      iex> create_influencer_account(%{field: value})
      {:ok, %InfluencerAccount{}}

      iex> create_influencer_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_influencer_account(attrs \\ %{}) do
    %InfluencerAccount{}
    |> InfluencerAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a influencer_account.

  ## Examples

      iex> update_influencer_account(influencer_account, %{field: new_value})
      {:ok, %InfluencerAccount{}}

      iex> update_influencer_account(influencer_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_influencer_account(%InfluencerAccount{} = influencer_account, attrs) do
    influencer_account
    |> InfluencerAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a influencer_account.

  ## Examples

      iex> delete_influencer_account(influencer_account)
      {:ok, %InfluencerAccount{}}

      iex> delete_influencer_account(influencer_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_influencer_account(%InfluencerAccount{} = influencer_account) do
    Repo.delete(influencer_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking influencer_account changes.

  ## Examples

      iex> change_influencer_account(influencer_account)
      %Ecto.Changeset{data: %InfluencerAccount{}}

  """
  def change_influencer_account(%InfluencerAccount{} = influencer_account, attrs \\ %{}) do
    InfluencerAccount.changeset(influencer_account, attrs)
  end
end
