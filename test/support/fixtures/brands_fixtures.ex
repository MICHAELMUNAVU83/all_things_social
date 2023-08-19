defmodule AllThingsSocial.BrandsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Brands` context.
  """

  def unique_brand_email, do: "brand#{System.unique_integer()}@example.com"
  def valid_brand_password, do: "hello world!"

  def valid_brand_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_brand_email(),
      password: valid_brand_password()
    })
  end

  def brand_fixture(attrs \\ %{}) do
    {:ok, brand} =
      attrs
      |> valid_brand_attributes()
      |> AllThingsSocial.Brands.register_brand()

    brand
  end

  def extract_brand_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
