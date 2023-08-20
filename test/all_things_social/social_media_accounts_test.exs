defmodule AllThingsSocial.SocialMediaAccountsTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.SocialMediaAccounts

  describe "social_media_accounts" do
    alias AllThingsSocial.SocialMediaAccounts.SocialMediaAccount

    import AllThingsSocial.SocialMediaAccountsFixtures

    @invalid_attrs %{account_url: nil, platform: nil}

    test "list_social_media_accounts/0 returns all social_media_accounts" do
      social_media_account = social_media_account_fixture()
      assert SocialMediaAccounts.list_social_media_accounts() == [social_media_account]
    end

    test "get_social_media_account!/1 returns the social_media_account with given id" do
      social_media_account = social_media_account_fixture()

      assert SocialMediaAccounts.get_social_media_account!(social_media_account.id) ==
               social_media_account
    end

    test "create_social_media_account/1 with valid data creates a social_media_account" do
      valid_attrs = %{account_url: "some account_url", platform: "some platform"}

      assert {:ok, %SocialMediaAccount{} = social_media_account} =
               SocialMediaAccounts.create_social_media_account(valid_attrs)

      assert social_media_account.account_url == "some account_url"
      assert social_media_account.platform == "some platform"
    end

    test "create_social_media_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               SocialMediaAccounts.create_social_media_account(@invalid_attrs)
    end

    test "update_social_media_account/2 with valid data updates the social_media_account" do
      social_media_account = social_media_account_fixture()
      update_attrs = %{account_url: "some updated account_url", platform: "some updated platform"}

      assert {:ok, %SocialMediaAccount{} = social_media_account} =
               SocialMediaAccounts.update_social_media_account(social_media_account, update_attrs)

      assert social_media_account.account_url == "some updated account_url"
      assert social_media_account.platform == "some updated platform"
    end

    test "update_social_media_account/2 with invalid data returns error changeset" do
      social_media_account = social_media_account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SocialMediaAccounts.update_social_media_account(
                 social_media_account,
                 @invalid_attrs
               )

      assert social_media_account ==
               SocialMediaAccounts.get_social_media_account!(social_media_account.id)
    end

    test "delete_social_media_account/1 deletes the social_media_account" do
      social_media_account = social_media_account_fixture()

      assert {:ok, %SocialMediaAccount{}} =
               SocialMediaAccounts.delete_social_media_account(social_media_account)

      assert_raise Ecto.NoResultsError, fn ->
        SocialMediaAccounts.get_social_media_account!(social_media_account.id)
      end
    end

    test "change_social_media_account/1 returns a social_media_account changeset" do
      social_media_account = social_media_account_fixture()

      assert %Ecto.Changeset{} =
               SocialMediaAccounts.change_social_media_account(social_media_account)
    end
  end
end
