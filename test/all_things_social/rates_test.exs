defmodule AllThingsSocial.RatesTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.Rates

  describe "rates" do
    alias AllThingsSocial.Rates.Rate

    import AllThingsSocial.RatesFixtures

    @invalid_attrs %{description: nil, platform: nil, amount: nil}

    test "list_rates/0 returns all rates" do
      rate = rate_fixture()
      assert Rates.list_rates() == [rate]
    end

    test "get_rate!/1 returns the rate with given id" do
      rate = rate_fixture()
      assert Rates.get_rate!(rate.id) == rate
    end

    test "create_rate/1 with valid data creates a rate" do
      valid_attrs = %{
        description: "some description",
        platform: "some platform",
        amount: "some amount"
      }

      assert {:ok, %Rate{} = rate} = Rates.create_rate(valid_attrs)
      assert rate.description == "some description"
      assert rate.platform == "some platform"
      assert rate.amount == "some amount"
    end

    test "create_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rates.create_rate(@invalid_attrs)
    end

    test "update_rate/2 with valid data updates the rate" do
      rate = rate_fixture()

      update_attrs = %{
        description: "some updated description",
        platform: "some updated platform",
        amount: "some updated amount"
      }

      assert {:ok, %Rate{} = rate} = Rates.update_rate(rate, update_attrs)
      assert rate.description == "some updated description"
      assert rate.platform == "some updated platform"
      assert rate.amount == "some updated amount"
    end

    test "update_rate/2 with invalid data returns error changeset" do
      rate = rate_fixture()
      assert {:error, %Ecto.Changeset{}} = Rates.update_rate(rate, @invalid_attrs)
      assert rate == Rates.get_rate!(rate.id)
    end

    test "delete_rate/1 deletes the rate" do
      rate = rate_fixture()
      assert {:ok, %Rate{}} = Rates.delete_rate(rate)
      assert_raise Ecto.NoResultsError, fn -> Rates.get_rate!(rate.id) end
    end

    test "change_rate/1 returns a rate changeset" do
      rate = rate_fixture()
      assert %Ecto.Changeset{} = Rates.change_rate(rate)
    end
  end
end
