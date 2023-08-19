defmodule AllThingsSocial.Niches do
  @moduledoc """
  The Niches context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.Niches.Niche

  @doc """
  Returns the list of niches.

  ## Examples

      iex> list_niches()
      [%Niche{}, ...]

  """
  def list_niches do
    Repo.all(Niche)
  end

  @doc """
  Gets a single niche.

  Raises `Ecto.NoResultsError` if the Niche does not exist.

  ## Examples

      iex> get_niche!(123)
      %Niche{}

      iex> get_niche!(456)
      ** (Ecto.NoResultsError)

  """
  def get_niche!(id), do: Repo.get!(Niche, id)

  @doc """
  Creates a niche.

  ## Examples

      iex> create_niche(%{field: value})
      {:ok, %Niche{}}

      iex> create_niche(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_niche(attrs \\ %{}) do
    %Niche{}
    |> Niche.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a niche.

  ## Examples

      iex> update_niche(niche, %{field: new_value})
      {:ok, %Niche{}}

      iex> update_niche(niche, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_niche(%Niche{} = niche, attrs) do
    niche
    |> Niche.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a niche.

  ## Examples

      iex> delete_niche(niche)
      {:ok, %Niche{}}

      iex> delete_niche(niche)
      {:error, %Ecto.Changeset{}}

  """
  def delete_niche(%Niche{} = niche) do
    Repo.delete(niche)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking niche changes.

  ## Examples

      iex> change_niche(niche)
      %Ecto.Changeset{data: %Niche{}}

  """
  def change_niche(%Niche{} = niche, attrs \\ %{}) do
    Niche.changeset(niche, attrs)
  end
end
