defmodule AllThingsSocial.SocialMediaAccounts do
  @moduledoc """
  The SocialMediaAccounts context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount

  @doc """
  Returns the list of social_media_accounts.

  ## Examples

      iex> list_social_media_accounts()
      [%SocialMediaAccount{}, ...]

  """
  def list_social_media_accounts do
    Repo.all(SocialMediaAccount)
  end

  @doc """
  Gets a single social_media_account.

  Raises `Ecto.NoResultsError` if the Social media account does not exist.

  ## Examples

      iex> get_social_media_account!(123)
      %SocialMediaAccount{}

      iex> get_social_media_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_social_media_account!(id), do: Repo.get!(SocialMediaAccount, id)

  @doc """
  Creates a social_media_account.

  ## Examples

      iex> create_social_media_account(%{field: value})
      {:ok, %SocialMediaAccount{}}

      iex> create_social_media_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_social_media_account(attrs \\ %{}) do
    %SocialMediaAccount{}
    |> SocialMediaAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a social_media_account.

  ## Examples

      iex> update_social_media_account(social_media_account, %{field: new_value})
      {:ok, %SocialMediaAccount{}}

      iex> update_social_media_account(social_media_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_social_media_account(%SocialMediaAccount{} = social_media_account, attrs) do
    social_media_account
    |> SocialMediaAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a social_media_account.

  ## Examples

      iex> delete_social_media_account(social_media_account)
      {:ok, %SocialMediaAccount{}}

      iex> delete_social_media_account(social_media_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_social_media_account(%SocialMediaAccount{} = social_media_account) do
    Repo.delete(social_media_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking social_media_account changes.

  ## Examples

      iex> change_social_media_account(social_media_account)
      %Ecto.Changeset{data: %SocialMediaAccount{}}

  """
  def change_social_media_account(%SocialMediaAccount{} = social_media_account, attrs \\ %{}) do
    SocialMediaAccount.changeset(social_media_account, attrs)
  end
end
