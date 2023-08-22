defmodule AllThingsSocial.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AllThingsSocial.Payments` context.
  """

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        status: "some status",
        price: "some price"
      })
      |> AllThingsSocial.Payments.create_payment()

    payment
  end
end
