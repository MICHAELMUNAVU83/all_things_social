defmodule AllThingsSocial.BrandsTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.Brands

  import AllThingsSocial.BrandsFixtures
  alias AllThingsSocial.Brands.{Brand, BrandToken}

  describe "get_brand_by_email/1" do
    test "does not return the brand if the email does not exist" do
      refute Brands.get_brand_by_email("unknown@example.com")
    end

    test "returns the brand if the email exists" do
      %{id: id} = brand = brand_fixture()
      assert %Brand{id: ^id} = Brands.get_brand_by_email(brand.email)
    end
  end

  describe "get_brand_by_email_and_password/2" do
    test "does not return the brand if the email does not exist" do
      refute Brands.get_brand_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the brand if the password is not valid" do
      brand = brand_fixture()
      refute Brands.get_brand_by_email_and_password(brand.email, "invalid")
    end

    test "returns the brand if the email and password are valid" do
      %{id: id} = brand = brand_fixture()

      assert %Brand{id: ^id} =
               Brands.get_brand_by_email_and_password(brand.email, valid_brand_password())
    end
  end

  describe "get_brand!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Brands.get_brand!(-1)
      end
    end

    test "returns the brand with the given id" do
      %{id: id} = brand = brand_fixture()
      assert %Brand{id: ^id} = Brands.get_brand!(brand.id)
    end
  end

  describe "register_brand/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Brands.register_brand(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Brands.register_brand(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Brands.register_brand(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = brand_fixture()
      {:error, changeset} = Brands.register_brand(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Brands.register_brand(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers brands with a hashed password" do
      email = unique_brand_email()
      {:ok, brand} = Brands.register_brand(valid_brand_attributes(email: email))
      assert brand.email == email
      assert is_binary(brand.hashed_password)
      assert is_nil(brand.confirmed_at)
      assert is_nil(brand.password)
    end
  end

  describe "change_brand_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Brands.change_brand_registration(%Brand{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_brand_email()
      password = valid_brand_password()

      changeset =
        Brands.change_brand_registration(
          %Brand{},
          valid_brand_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_brand_email/2" do
    test "returns a brand changeset" do
      assert %Ecto.Changeset{} = changeset = Brands.change_brand_email(%Brand{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_brand_email/3" do
    setup do
      %{brand: brand_fixture()}
    end

    test "requires email to change", %{brand: brand} do
      {:error, changeset} = Brands.apply_brand_email(brand, valid_brand_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{brand: brand} do
      {:error, changeset} =
        Brands.apply_brand_email(brand, valid_brand_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{brand: brand} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Brands.apply_brand_email(brand, valid_brand_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{brand: brand} do
      %{email: email} = brand_fixture()

      {:error, changeset} =
        Brands.apply_brand_email(brand, valid_brand_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{brand: brand} do
      {:error, changeset} =
        Brands.apply_brand_email(brand, "invalid", %{email: unique_brand_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{brand: brand} do
      email = unique_brand_email()
      {:ok, brand} = Brands.apply_brand_email(brand, valid_brand_password(), %{email: email})
      assert brand.email == email
      assert Brands.get_brand!(brand.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{brand: brand_fixture()}
    end

    test "sends token through notification", %{brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_update_email_instructions(brand, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert brand_token = Repo.get_by(BrandToken, token: :crypto.hash(:sha256, token))
      assert brand_token.brand_id == brand.id
      assert brand_token.sent_to == brand.email
      assert brand_token.context == "change:current@example.com"
    end
  end

  describe "update_brand_email/2" do
    setup do
      brand = brand_fixture()
      email = unique_brand_email()

      token =
        extract_brand_token(fn url ->
          Brands.deliver_update_email_instructions(%{brand | email: email}, brand.email, url)
        end)

      %{brand: brand, token: token, email: email}
    end

    test "updates the email with a valid token", %{brand: brand, token: token, email: email} do
      assert Brands.update_brand_email(brand, token) == :ok
      changed_brand = Repo.get!(Brand, brand.id)
      assert changed_brand.email != brand.email
      assert changed_brand.email == email
      assert changed_brand.confirmed_at
      assert changed_brand.confirmed_at != brand.confirmed_at
      refute Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not update email with invalid token", %{brand: brand} do
      assert Brands.update_brand_email(brand, "oops") == :error
      assert Repo.get!(Brand, brand.id).email == brand.email
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not update email if brand email changed", %{brand: brand, token: token} do
      assert Brands.update_brand_email(%{brand | email: "current@example.com"}, token) == :error
      assert Repo.get!(Brand, brand.id).email == brand.email
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not update email if token expired", %{brand: brand, token: token} do
      {1, nil} = Repo.update_all(BrandToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Brands.update_brand_email(brand, token) == :error
      assert Repo.get!(Brand, brand.id).email == brand.email
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end
  end

  describe "change_brand_password/2" do
    test "returns a brand changeset" do
      assert %Ecto.Changeset{} = changeset = Brands.change_brand_password(%Brand{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Brands.change_brand_password(%Brand{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_brand_password/3" do
    setup do
      %{brand: brand_fixture()}
    end

    test "validates password", %{brand: brand} do
      {:error, changeset} =
        Brands.update_brand_password(brand, valid_brand_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{brand: brand} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Brands.update_brand_password(brand, valid_brand_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{brand: brand} do
      {:error, changeset} =
        Brands.update_brand_password(brand, "invalid", %{password: valid_brand_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{brand: brand} do
      {:ok, brand} =
        Brands.update_brand_password(brand, valid_brand_password(), %{
          password: "new valid password"
        })

      assert is_nil(brand.password)
      assert Brands.get_brand_by_email_and_password(brand.email, "new valid password")
    end

    test "deletes all tokens for the given brand", %{brand: brand} do
      _ = Brands.generate_brand_session_token(brand)

      {:ok, _} =
        Brands.update_brand_password(brand, valid_brand_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(BrandToken, brand_id: brand.id)
    end
  end

  describe "generate_brand_session_token/1" do
    setup do
      %{brand: brand_fixture()}
    end

    test "generates a token", %{brand: brand} do
      token = Brands.generate_brand_session_token(brand)
      assert brand_token = Repo.get_by(BrandToken, token: token)
      assert brand_token.context == "session"

      # Creating the same token for another brand should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%BrandToken{
          token: brand_token.token,
          brand_id: brand_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_brand_by_session_token/1" do
    setup do
      brand = brand_fixture()
      token = Brands.generate_brand_session_token(brand)
      %{brand: brand, token: token}
    end

    test "returns brand by token", %{brand: brand, token: token} do
      assert session_brand = Brands.get_brand_by_session_token(token)
      assert session_brand.id == brand.id
    end

    test "does not return brand for invalid token" do
      refute Brands.get_brand_by_session_token("oops")
    end

    test "does not return brand for expired token", %{token: token} do
      {1, nil} = Repo.update_all(BrandToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Brands.get_brand_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      brand = brand_fixture()
      token = Brands.generate_brand_session_token(brand)
      assert Brands.delete_session_token(token) == :ok
      refute Brands.get_brand_by_session_token(token)
    end
  end

  describe "deliver_brand_confirmation_instructions/2" do
    setup do
      %{brand: brand_fixture()}
    end

    test "sends token through notification", %{brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_confirmation_instructions(brand, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert brand_token = Repo.get_by(BrandToken, token: :crypto.hash(:sha256, token))
      assert brand_token.brand_id == brand.id
      assert brand_token.sent_to == brand.email
      assert brand_token.context == "confirm"
    end
  end

  describe "confirm_brand/1" do
    setup do
      brand = brand_fixture()

      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_confirmation_instructions(brand, url)
        end)

      %{brand: brand, token: token}
    end

    test "confirms the email with a valid token", %{brand: brand, token: token} do
      assert {:ok, confirmed_brand} = Brands.confirm_brand(token)
      assert confirmed_brand.confirmed_at
      assert confirmed_brand.confirmed_at != brand.confirmed_at
      assert Repo.get!(Brand, brand.id).confirmed_at
      refute Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not confirm with invalid token", %{brand: brand} do
      assert Brands.confirm_brand("oops") == :error
      refute Repo.get!(Brand, brand.id).confirmed_at
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not confirm email if token expired", %{brand: brand, token: token} do
      {1, nil} = Repo.update_all(BrandToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Brands.confirm_brand(token) == :error
      refute Repo.get!(Brand, brand.id).confirmed_at
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end
  end

  describe "deliver_brand_reset_password_instructions/2" do
    setup do
      %{brand: brand_fixture()}
    end

    test "sends token through notification", %{brand: brand} do
      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_reset_password_instructions(brand, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert brand_token = Repo.get_by(BrandToken, token: :crypto.hash(:sha256, token))
      assert brand_token.brand_id == brand.id
      assert brand_token.sent_to == brand.email
      assert brand_token.context == "reset_password"
    end
  end

  describe "get_brand_by_reset_password_token/1" do
    setup do
      brand = brand_fixture()

      token =
        extract_brand_token(fn url ->
          Brands.deliver_brand_reset_password_instructions(brand, url)
        end)

      %{brand: brand, token: token}
    end

    test "returns the brand with valid token", %{brand: %{id: id}, token: token} do
      assert %Brand{id: ^id} = Brands.get_brand_by_reset_password_token(token)
      assert Repo.get_by(BrandToken, brand_id: id)
    end

    test "does not return the brand with invalid token", %{brand: brand} do
      refute Brands.get_brand_by_reset_password_token("oops")
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end

    test "does not return the brand if token expired", %{brand: brand, token: token} do
      {1, nil} = Repo.update_all(BrandToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Brands.get_brand_by_reset_password_token(token)
      assert Repo.get_by(BrandToken, brand_id: brand.id)
    end
  end

  describe "reset_brand_password/2" do
    setup do
      %{brand: brand_fixture()}
    end

    test "validates password", %{brand: brand} do
      {:error, changeset} =
        Brands.reset_brand_password(brand, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{brand: brand} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Brands.reset_brand_password(brand, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{brand: brand} do
      {:ok, updated_brand} = Brands.reset_brand_password(brand, %{password: "new valid password"})
      assert is_nil(updated_brand.password)
      assert Brands.get_brand_by_email_and_password(brand.email, "new valid password")
    end

    test "deletes all tokens for the given brand", %{brand: brand} do
      _ = Brands.generate_brand_session_token(brand)
      {:ok, _} = Brands.reset_brand_password(brand, %{password: "new valid password"})
      refute Repo.get_by(BrandToken, brand_id: brand.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Brand{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
