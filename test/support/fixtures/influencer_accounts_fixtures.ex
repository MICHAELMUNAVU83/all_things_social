defmodule AllThingsSocial.InfluencerAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.InfluencerAccounts` context.
  """

  @doc """
  Generate a influencer_account.
  """
  def influencer_account_fixture(attrs \\ %{}) do
    {:ok, influencer_account} =
      attrs
      |> Enum.into(%{
        column: "some column"
      })
      |> AllThingsSocial.InfluencerAccounts.create_influencer_account()

    influencer_account
  end
end
