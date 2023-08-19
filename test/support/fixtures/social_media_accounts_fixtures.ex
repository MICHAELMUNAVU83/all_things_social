defmodule AllThingsSocial.SocialMediaAccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.SocialMediaAccounts` context.
  """

  @doc """
  Generate a social_media_account.
  """
  def social_media_account_fixture(attrs \\ %{}) do
    {:ok, social_media_account} =
      attrs
      |> Enum.into(%{
        account_url: "some account_url",
        platform: "some platform"
      })
      |> AllThingsSocial.SocialMediaAccounts.create_social_media_account()

    social_media_account
  end
end
