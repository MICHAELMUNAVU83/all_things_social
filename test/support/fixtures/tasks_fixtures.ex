defmodule AllThingsSocial.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        name: "some name",
        status: "some status",
        description: "some description",
        price: "some price"
      })
      |> AllThingsSocial.Tasks.create_task()

    task
  end
end
