defmodule AllThingsSocial.ContentBoardsTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.ContentBoards

  describe "content_boards" do
    alias AllThingsSocial.ContentBoards.ContentBoard

    import AllThingsSocial.ContentBoardsFixtures

    @invalid_attrs %{name: nil}

    test "list_content_boards/0 returns all content_boards" do
      content_board = content_board_fixture()
      assert ContentBoards.list_content_boards() == [content_board]
    end

    test "get_content_board!/1 returns the content_board with given id" do
      content_board = content_board_fixture()
      assert ContentBoards.get_content_board!(content_board.id) == content_board
    end

    test "create_content_board/1 with valid data creates a content_board" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ContentBoard{} = content_board} =
               ContentBoards.create_content_board(valid_attrs)

      assert content_board.name == "some name"
    end

    test "create_content_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ContentBoards.create_content_board(@invalid_attrs)
    end

    test "update_content_board/2 with valid data updates the content_board" do
      content_board = content_board_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ContentBoard{} = content_board} =
               ContentBoards.update_content_board(content_board, update_attrs)

      assert content_board.name == "some updated name"
    end

    test "update_content_board/2 with invalid data returns error changeset" do
      content_board = content_board_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ContentBoards.update_content_board(content_board, @invalid_attrs)

      assert content_board == ContentBoards.get_content_board!(content_board.id)
    end

    test "delete_content_board/1 deletes the content_board" do
      content_board = content_board_fixture()
      assert {:ok, %ContentBoard{}} = ContentBoards.delete_content_board(content_board)

      assert_raise Ecto.NoResultsError, fn ->
        ContentBoards.get_content_board!(content_board.id)
      end
    end

    test "change_content_board/1 returns a content_board changeset" do
      content_board = content_board_fixture()
      assert %Ecto.Changeset{} = ContentBoards.change_content_board(content_board)
    end
  end
end
