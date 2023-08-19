defmodule AllThingsSocial.ContentBoards do
  @moduledoc """
  The ContentBoards context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.ContentBoards.ContentBoard

  @doc """
  Returns the list of content_boards.

  ## Examples

      iex> list_content_boards()
      [%ContentBoard{}, ...]

  """
  def list_content_boards do
    Repo.all(ContentBoard)
  end

  @doc """
  Gets a single content_board.

  Raises `Ecto.NoResultsError` if the Content board does not exist.

  ## Examples

      iex> get_content_board!(123)
      %ContentBoard{}

      iex> get_content_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content_board!(id), do: Repo.get!(ContentBoard, id)

  @doc """
  Creates a content_board.

  ## Examples

      iex> create_content_board(%{field: value})
      {:ok, %ContentBoard{}}

      iex> create_content_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content_board(attrs \\ %{}) do
    %ContentBoard{}
    |> ContentBoard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a content_board.

  ## Examples

      iex> update_content_board(content_board, %{field: new_value})
      {:ok, %ContentBoard{}}

      iex> update_content_board(content_board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content_board(%ContentBoard{} = content_board, attrs) do
    content_board
    |> ContentBoard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a content_board.

  ## Examples

      iex> delete_content_board(content_board)
      {:ok, %ContentBoard{}}

      iex> delete_content_board(content_board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content_board(%ContentBoard{} = content_board) do
    Repo.delete(content_board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content_board changes.

  ## Examples

      iex> change_content_board(content_board)
      %Ecto.Changeset{data: %ContentBoard{}}

  """
  def change_content_board(%ContentBoard{} = content_board, attrs \\ %{}) do
    ContentBoard.changeset(content_board, attrs)
  end
end
