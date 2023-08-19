defmodule AllThingsSocial.NichesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Niches` context.
  """

  @doc """
  Generate a niche.
  """
  def niche_fixture(attrs \\ %{}) do
    {:ok, niche} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> AllThingsSocial.Niches.create_niche()

    niche
  end
end
