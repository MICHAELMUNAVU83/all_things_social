defmodule AllThingsSocial.Rates do
  @moduledoc """
  The Rates context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.Rates.Rate

  @doc """
  Returns the list of rates.

  ## Examples

      iex> list_rates()
      [%Rate{}, ...]

  """
  def list_rates do
    Repo.all(Rate)
  end

  @doc """
  Gets a single rate.

  Raises `Ecto.NoResultsError` if the Rate does not exist.

  ## Examples

      iex> get_rate!(123)
      %Rate{}

      iex> get_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rate!(id), do: Repo.get!(Rate, id)

  @doc """
  Creates a rate.

  ## Examples

      iex> create_rate(%{field: value})
      {:ok, %Rate{}}

      iex> create_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rate(attrs \\ %{}) do
    %Rate{}
    |> Rate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rate.

  ## Examples

      iex> update_rate(rate, %{field: new_value})
      {:ok, %Rate{}}

      iex> update_rate(rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rate(%Rate{} = rate, attrs) do
    rate
    |> Rate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rate.

  ## Examples

      iex> delete_rate(rate)
      {:ok, %Rate{}}

      iex> delete_rate(rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rate(%Rate{} = rate) do
    Repo.delete(rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rate changes.

  ## Examples

      iex> change_rate(rate)
      %Ecto.Changeset{data: %Rate{}}

  """
  def change_rate(%Rate{} = rate, attrs \\ %{}) do
    Rate.changeset(rate, attrs)
  end
end
