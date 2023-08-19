defmodule AllThingsSocial.InfluencersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Influencers` context.
  """

  def unique_influencer_email, do: "influencer#{System.unique_integer()}@example.com"
  def valid_influencer_password, do: "hello world!"

  def valid_influencer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_influencer_email(),
      password: valid_influencer_password()
    })
  end

  def influencer_fixture(attrs \\ %{}) do
    {:ok, influencer} =
      attrs
      |> valid_influencer_attributes()
      |> AllThingsSocial.Influencers.register_influencer()

    influencer
  end

  def extract_influencer_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
