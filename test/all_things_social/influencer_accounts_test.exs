defmodule AllThingsSocial.InfluencerAccountsTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.InfluencerAccounts

  describe "influencer_accounts" do
    alias AllThingsSocial.InfluencerAccounts.InfluencerAccount

    import AllThingsSocial.InfluencerAccountsFixtures

    @invalid_attrs %{column: nil}

    test "list_influencer_accounts/0 returns all influencer_accounts" do
      influencer_account = influencer_account_fixture()
      assert InfluencerAccounts.list_influencer_accounts() == [influencer_account]
    end

    test "get_influencer_account!/1 returns the influencer_account with given id" do
      influencer_account = influencer_account_fixture()
      assert InfluencerAccounts.get_influencer_account!(influencer_account.id) == influencer_account
    end

    test "create_influencer_account/1 with valid data creates a influencer_account" do
      valid_attrs = %{column: "some column"}

      assert {:ok, %InfluencerAccount{} = influencer_account} = InfluencerAccounts.create_influencer_account(valid_attrs)
      assert influencer_account.column == "some column"
    end

    test "create_influencer_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InfluencerAccounts.create_influencer_account(@invalid_attrs)
    end

    test "update_influencer_account/2 with valid data updates the influencer_account" do
      influencer_account = influencer_account_fixture()
      update_attrs = %{column: "some updated column"}

      assert {:ok, %InfluencerAccount{} = influencer_account} = InfluencerAccounts.update_influencer_account(influencer_account, update_attrs)
      assert influencer_account.column == "some updated column"
    end

    test "update_influencer_account/2 with invalid data returns error changeset" do
      influencer_account = influencer_account_fixture()
      assert {:error, %Ecto.Changeset{}} = InfluencerAccounts.update_influencer_account(influencer_account, @invalid_attrs)
      assert influencer_account == InfluencerAccounts.get_influencer_account!(influencer_account.id)
    end

    test "delete_influencer_account/1 deletes the influencer_account" do
      influencer_account = influencer_account_fixture()
      assert {:ok, %InfluencerAccount{}} = InfluencerAccounts.delete_influencer_account(influencer_account)
      assert_raise Ecto.NoResultsError, fn -> InfluencerAccounts.get_influencer_account!(influencer_account.id) end
    end

    test "change_influencer_account/1 returns a influencer_account changeset" do
      influencer_account = influencer_account_fixture()
      assert %Ecto.Changeset{} = InfluencerAccounts.change_influencer_account(influencer_account)
    end
  end
end
