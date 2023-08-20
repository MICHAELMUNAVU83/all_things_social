defmodule AllThingsSocial.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        message: "some message"
      })
      |> AllThingsSocial.Chats.create_chat()

    chat
  end
end
