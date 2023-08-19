defmodule AllThingsSocial.ContentBoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.ContentBoards` context.
  """

  @doc """
  Generate a content_board.
  """
  def content_board_fixture(attrs \\ %{}) do
    {:ok, content_board} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> AllThingsSocial.ContentBoards.create_content_board()

    content_board
  end
end
