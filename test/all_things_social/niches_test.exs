defmodule AllThingsSocial.NichesTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.Niches

  describe "niches" do
    alias AllThingsSocial.Niches.Niche

    import AllThingsSocial.NichesFixtures

    @invalid_attrs %{name: nil}

    test "list_niches/0 returns all niches" do
      niche = niche_fixture()
      assert Niches.list_niches() == [niche]
    end

    test "get_niche!/1 returns the niche with given id" do
      niche = niche_fixture()
      assert Niches.get_niche!(niche.id) == niche
    end

    test "create_niche/1 with valid data creates a niche" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Niche{} = niche} = Niches.create_niche(valid_attrs)
      assert niche.name == "some name"
    end

    test "create_niche/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Niches.create_niche(@invalid_attrs)
    end

    test "update_niche/2 with valid data updates the niche" do
      niche = niche_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Niche{} = niche} = Niches.update_niche(niche, update_attrs)
      assert niche.name == "some updated name"
    end

    test "update_niche/2 with invalid data returns error changeset" do
      niche = niche_fixture()
      assert {:error, %Ecto.Changeset{}} = Niches.update_niche(niche, @invalid_attrs)
      assert niche == Niches.get_niche!(niche.id)
    end

    test "delete_niche/1 deletes the niche" do
      niche = niche_fixture()
      assert {:ok, %Niche{}} = Niches.delete_niche(niche)
      assert_raise Ecto.NoResultsError, fn -> Niches.get_niche!(niche.id) end
    end

    test "change_niche/1 returns a niche changeset" do
      niche = niche_fixture()
      assert %Ecto.Changeset{} = Niches.change_niche(niche)
    end
  end
end
