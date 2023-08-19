defmodule AllThingsSocial.RatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Rates` context.
  """

  @doc """
  Generate a rate.
  """
  def rate_fixture(attrs \\ %{}) do
    {:ok, rate} =
      attrs
      |> Enum.into(%{
        description: "some description",
        platform: "some platform",
        amount: "some amount"
      })
      |> AllThingsSocial.Rates.create_rate()

    rate
  end
end
