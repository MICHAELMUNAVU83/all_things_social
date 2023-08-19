defmodule AllThingsSocial.InfluencersTest do
  use AllThingsSocial.DataCase

  alias AllThingsSocial.Influencers

  import AllThingsSocial.InfluencersFixtures
  alias AllThingsSocial.Influencers.{Influencer, InfluencerToken}

  describe "get_influencer_by_email/1" do
    test "does not return the influencer if the email does not exist" do
      refute Influencers.get_influencer_by_email("unknown@example.com")
    end

    test "returns the influencer if the email exists" do
      %{id: id} = influencer = influencer_fixture()
      assert %Influencer{id: ^id} = Influencers.get_influencer_by_email(influencer.email)
    end
  end

  describe "get_influencer_by_email_and_password/2" do
    test "does not return the influencer if the email does not exist" do
      refute Influencers.get_influencer_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the influencer if the password is not valid" do
      influencer = influencer_fixture()
      refute Influencers.get_influencer_by_email_and_password(influencer.email, "invalid")
    end

    test "returns the influencer if the email and password are valid" do
      %{id: id} = influencer = influencer_fixture()

      assert %Influencer{id: ^id} =
               Influencers.get_influencer_by_email_and_password(influencer.email, valid_influencer_password())
    end
  end

  describe "get_influencer!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Influencers.get_influencer!(-1)
      end
    end

    test "returns the influencer with the given id" do
      %{id: id} = influencer = influencer_fixture()
      assert %Influencer{id: ^id} = Influencers.get_influencer!(influencer.id)
    end
  end

  describe "register_influencer/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Influencers.register_influencer(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Influencers.register_influencer(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Influencers.register_influencer(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = influencer_fixture()
      {:error, changeset} = Influencers.register_influencer(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Influencers.register_influencer(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers influencers with a hashed password" do
      email = unique_influencer_email()
      {:ok, influencer} = Influencers.register_influencer(valid_influencer_attributes(email: email))
      assert influencer.email == email
      assert is_binary(influencer.hashed_password)
      assert is_nil(influencer.confirmed_at)
      assert is_nil(influencer.password)
    end
  end

  describe "change_influencer_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Influencers.change_influencer_registration(%Influencer{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_influencer_email()
      password = valid_influencer_password()

      changeset =
        Influencers.change_influencer_registration(
          %Influencer{},
          valid_influencer_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_influencer_email/2" do
    test "returns a influencer changeset" do
      assert %Ecto.Changeset{} = changeset = Influencers.change_influencer_email(%Influencer{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_influencer_email/3" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "requires email to change", %{influencer: influencer} do
      {:error, changeset} = Influencers.apply_influencer_email(influencer, valid_influencer_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{influencer: influencer} do
      {:error, changeset} =
        Influencers.apply_influencer_email(influencer, valid_influencer_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{influencer: influencer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Influencers.apply_influencer_email(influencer, valid_influencer_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{influencer: influencer} do
      %{email: email} = influencer_fixture()

      {:error, changeset} =
        Influencers.apply_influencer_email(influencer, valid_influencer_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{influencer: influencer} do
      {:error, changeset} =
        Influencers.apply_influencer_email(influencer, "invalid", %{email: unique_influencer_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{influencer: influencer} do
      email = unique_influencer_email()
      {:ok, influencer} = Influencers.apply_influencer_email(influencer, valid_influencer_password(), %{email: email})
      assert influencer.email == email
      assert Influencers.get_influencer!(influencer.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "sends token through notification", %{influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_update_email_instructions(influencer, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert influencer_token = Repo.get_by(InfluencerToken, token: :crypto.hash(:sha256, token))
      assert influencer_token.influencer_id == influencer.id
      assert influencer_token.sent_to == influencer.email
      assert influencer_token.context == "change:current@example.com"
    end
  end

  describe "update_influencer_email/2" do
    setup do
      influencer = influencer_fixture()
      email = unique_influencer_email()

      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_update_email_instructions(%{influencer | email: email}, influencer.email, url)
        end)

      %{influencer: influencer, token: token, email: email}
    end

    test "updates the email with a valid token", %{influencer: influencer, token: token, email: email} do
      assert Influencers.update_influencer_email(influencer, token) == :ok
      changed_influencer = Repo.get!(Influencer, influencer.id)
      assert changed_influencer.email != influencer.email
      assert changed_influencer.email == email
      assert changed_influencer.confirmed_at
      assert changed_influencer.confirmed_at != influencer.confirmed_at
      refute Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not update email with invalid token", %{influencer: influencer} do
      assert Influencers.update_influencer_email(influencer, "oops") == :error
      assert Repo.get!(Influencer, influencer.id).email == influencer.email
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not update email if influencer email changed", %{influencer: influencer, token: token} do
      assert Influencers.update_influencer_email(%{influencer | email: "current@example.com"}, token) == :error
      assert Repo.get!(Influencer, influencer.id).email == influencer.email
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not update email if token expired", %{influencer: influencer, token: token} do
      {1, nil} = Repo.update_all(InfluencerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Influencers.update_influencer_email(influencer, token) == :error
      assert Repo.get!(Influencer, influencer.id).email == influencer.email
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end
  end

  describe "change_influencer_password/2" do
    test "returns a influencer changeset" do
      assert %Ecto.Changeset{} = changeset = Influencers.change_influencer_password(%Influencer{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Influencers.change_influencer_password(%Influencer{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_influencer_password/3" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "validates password", %{influencer: influencer} do
      {:error, changeset} =
        Influencers.update_influencer_password(influencer, valid_influencer_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{influencer: influencer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Influencers.update_influencer_password(influencer, valid_influencer_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{influencer: influencer} do
      {:error, changeset} =
        Influencers.update_influencer_password(influencer, "invalid", %{password: valid_influencer_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{influencer: influencer} do
      {:ok, influencer} =
        Influencers.update_influencer_password(influencer, valid_influencer_password(), %{
          password: "new valid password"
        })

      assert is_nil(influencer.password)
      assert Influencers.get_influencer_by_email_and_password(influencer.email, "new valid password")
    end

    test "deletes all tokens for the given influencer", %{influencer: influencer} do
      _ = Influencers.generate_influencer_session_token(influencer)

      {:ok, _} =
        Influencers.update_influencer_password(influencer, valid_influencer_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end
  end

  describe "generate_influencer_session_token/1" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "generates a token", %{influencer: influencer} do
      token = Influencers.generate_influencer_session_token(influencer)
      assert influencer_token = Repo.get_by(InfluencerToken, token: token)
      assert influencer_token.context == "session"

      # Creating the same token for another influencer should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%InfluencerToken{
          token: influencer_token.token,
          influencer_id: influencer_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_influencer_by_session_token/1" do
    setup do
      influencer = influencer_fixture()
      token = Influencers.generate_influencer_session_token(influencer)
      %{influencer: influencer, token: token}
    end

    test "returns influencer by token", %{influencer: influencer, token: token} do
      assert session_influencer = Influencers.get_influencer_by_session_token(token)
      assert session_influencer.id == influencer.id
    end

    test "does not return influencer for invalid token" do
      refute Influencers.get_influencer_by_session_token("oops")
    end

    test "does not return influencer for expired token", %{token: token} do
      {1, nil} = Repo.update_all(InfluencerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Influencers.get_influencer_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      influencer = influencer_fixture()
      token = Influencers.generate_influencer_session_token(influencer)
      assert Influencers.delete_session_token(token) == :ok
      refute Influencers.get_influencer_by_session_token(token)
    end
  end

  describe "deliver_influencer_confirmation_instructions/2" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "sends token through notification", %{influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_confirmation_instructions(influencer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert influencer_token = Repo.get_by(InfluencerToken, token: :crypto.hash(:sha256, token))
      assert influencer_token.influencer_id == influencer.id
      assert influencer_token.sent_to == influencer.email
      assert influencer_token.context == "confirm"
    end
  end

  describe "confirm_influencer/1" do
    setup do
      influencer = influencer_fixture()

      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_confirmation_instructions(influencer, url)
        end)

      %{influencer: influencer, token: token}
    end

    test "confirms the email with a valid token", %{influencer: influencer, token: token} do
      assert {:ok, confirmed_influencer} = Influencers.confirm_influencer(token)
      assert confirmed_influencer.confirmed_at
      assert confirmed_influencer.confirmed_at != influencer.confirmed_at
      assert Repo.get!(Influencer, influencer.id).confirmed_at
      refute Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not confirm with invalid token", %{influencer: influencer} do
      assert Influencers.confirm_influencer("oops") == :error
      refute Repo.get!(Influencer, influencer.id).confirmed_at
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not confirm email if token expired", %{influencer: influencer, token: token} do
      {1, nil} = Repo.update_all(InfluencerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Influencers.confirm_influencer(token) == :error
      refute Repo.get!(Influencer, influencer.id).confirmed_at
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end
  end

  describe "deliver_influencer_reset_password_instructions/2" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "sends token through notification", %{influencer: influencer} do
      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_reset_password_instructions(influencer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert influencer_token = Repo.get_by(InfluencerToken, token: :crypto.hash(:sha256, token))
      assert influencer_token.influencer_id == influencer.id
      assert influencer_token.sent_to == influencer.email
      assert influencer_token.context == "reset_password"
    end
  end

  describe "get_influencer_by_reset_password_token/1" do
    setup do
      influencer = influencer_fixture()

      token =
        extract_influencer_token(fn url ->
          Influencers.deliver_influencer_reset_password_instructions(influencer, url)
        end)

      %{influencer: influencer, token: token}
    end

    test "returns the influencer with valid token", %{influencer: %{id: id}, token: token} do
      assert %Influencer{id: ^id} = Influencers.get_influencer_by_reset_password_token(token)
      assert Repo.get_by(InfluencerToken, influencer_id: id)
    end

    test "does not return the influencer with invalid token", %{influencer: influencer} do
      refute Influencers.get_influencer_by_reset_password_token("oops")
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end

    test "does not return the influencer if token expired", %{influencer: influencer, token: token} do
      {1, nil} = Repo.update_all(InfluencerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Influencers.get_influencer_by_reset_password_token(token)
      assert Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end
  end

  describe "reset_influencer_password/2" do
    setup do
      %{influencer: influencer_fixture()}
    end

    test "validates password", %{influencer: influencer} do
      {:error, changeset} =
        Influencers.reset_influencer_password(influencer, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{influencer: influencer} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Influencers.reset_influencer_password(influencer, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{influencer: influencer} do
      {:ok, updated_influencer} = Influencers.reset_influencer_password(influencer, %{password: "new valid password"})
      assert is_nil(updated_influencer.password)
      assert Influencers.get_influencer_by_email_and_password(influencer.email, "new valid password")
    end

    test "deletes all tokens for the given influencer", %{influencer: influencer} do
      _ = Influencers.generate_influencer_session_token(influencer)
      {:ok, _} = Influencers.reset_influencer_password(influencer, %{password: "new valid password"})
      refute Repo.get_by(InfluencerToken, influencer_id: influencer.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Influencer{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
