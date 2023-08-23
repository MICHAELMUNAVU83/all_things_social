defmodule AllThingsSocial.Influencers do
  @moduledoc """
  The Influencers context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.Influencers.{Influencer, InfluencerToken, InfluencerNotifier}

  ## Database getters

  @doc """
  Gets a influencer by email.

  ## Examples

      iex> get_influencer_by_email("foo@example.com")
      %Influencer{}

      iex> get_influencer_by_email("unknown@example.com")
      nil

  """
  def get_influencer_by_email(email) when is_binary(email) do
    Repo.get_by(Influencer, email: email)
  end

  def list_influencers do
    Repo.all(Influencer)
    |> Repo.preload(:niches)
  end

  def list_influencers_by_search(search) do
    if search == "" do
      query =
        Repo.all(Influencer)
        |> Repo.preload(:niches)
    else
    query =
      Repo.all(Influencer)
      |> Enum.filter(fn influencer ->
        String.contains?(String.downcase(influencer.username), String.downcase(search))
      end)
      |> Repo.preload(:niches)
    end
  end

  def list_influencers_by_niches(niche) do
    if niche == "" do
      query =
        Repo.all(Influencer)
        |> Repo.preload(:niches)
    else
      query =
        Repo.all(Influencer)
        |> Repo.preload(:niches)
        |> Enum.filter(fn influencer ->
          Enum.any?(influencer.niches, fn n -> n.name == niche end)
        end)
    end
  end


  def get_niches_for_an_influencer(id) do
    from(i in Influencer, where: i.id == ^id)
    |> Repo.one()
    |> Repo.preload(:niches)

  end

  @doc """
  Gets a influencer by email and password.

  ## Examples

      iex> get_influencer_by_email_and_password("foo@example.com", "correct_password")
      %Influencer{}

      iex> get_influencer_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_influencer_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    influencer = Repo.get_by(Influencer, email: email)
    if Influencer.valid_password?(influencer, password), do: influencer
  end

  @doc """
  Gets a single influencer.

  Raises `Ecto.NoResultsError` if the Influencer does not exist.

  ## Examples

      iex> get_influencer!(123)
      %Influencer{}

      iex> get_influencer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_influencer!(id), do: Repo.get!(Influencer, id)

  ## Influencer registration

  @doc """
  Registers a influencer.

  ## Examples

      iex> register_influencer(%{field: value})
      {:ok, %Influencer{}}

      iex> register_influencer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_influencer(attrs) do
    %Influencer{}
    |> Influencer.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking influencer changes.

  ## Examples

      iex> change_influencer_registration(influencer)
      %Ecto.Changeset{data: %Influencer{}}

  """
  def change_influencer_registration(%Influencer{} = influencer, attrs \\ %{}) do
    Influencer.registration_changeset(influencer, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the influencer email.

  ## Examples

      iex> change_influencer_email(influencer)
      %Ecto.Changeset{data: %Influencer{}}

  """
  def change_influencer_email(influencer, attrs \\ %{}) do
    Influencer.email_changeset(influencer, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_influencer_email(influencer, "valid password", %{email: ...})
      {:ok, %Influencer{}}

      iex> apply_influencer_email(influencer, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_influencer_email(influencer, password, attrs) do
    influencer
    |> Influencer.email_changeset(attrs)
    |> Influencer.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the influencer email using the given token.

  If the token matches, the influencer email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_influencer_email(influencer, token) do
    context = "change:#{influencer.email}"

    with {:ok, query} <- InfluencerToken.verify_change_email_token_query(token, context),
         %InfluencerToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(influencer_email_multi(influencer, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp influencer_email_multi(influencer, email, context) do
    changeset =
      influencer
      |> Influencer.email_changeset(%{email: email})
      |> Influencer.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:influencer, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      InfluencerToken.influencer_and_contexts_query(influencer, [context])
    )
  end

  @doc """
  Delivers the update email instructions to the given influencer.

  ## Examples

      iex> deliver_update_email_instructions(influencer, current_email, &Routes.influencer_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(
        %Influencer{} = influencer,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, influencer_token} =
      InfluencerToken.build_email_token(influencer, "change:#{current_email}")

    Repo.insert!(influencer_token)

    InfluencerNotifier.deliver_update_email_instructions(
      influencer,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the influencer password.

  ## Examples

      iex> change_influencer_password(influencer)
      %Ecto.Changeset{data: %Influencer{}}

  """
  def change_influencer_password(influencer, attrs \\ %{}) do
    Influencer.password_changeset(influencer, attrs, hash_password: false)
  end

  @doc """
  Updates the influencer password.

  ## Examples

      iex> update_influencer_password(influencer, "valid password", %{password: ...})
      {:ok, %Influencer{}}

      iex> update_influencer_password(influencer, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_influencer_password(influencer, password, attrs) do
    changeset =
      influencer
      |> Influencer.password_changeset(attrs)
      |> Influencer.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:influencer, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      InfluencerToken.influencer_and_contexts_query(influencer, :all)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{influencer: influencer}} -> {:ok, influencer}
      {:error, :influencer, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_influencer_session_token(influencer) do
    {token, influencer_token} = InfluencerToken.build_session_token(influencer)
    Repo.insert!(influencer_token)
    token
  end

  @doc """
  Gets the influencer with the given signed token.
  """
  def get_influencer_by_session_token(token) do
    {:ok, query} = InfluencerToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(InfluencerToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given influencer.

  ## Examples

      iex> deliver_influencer_confirmation_instructions(influencer, &Routes.influencer_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_influencer_confirmation_instructions(confirmed_influencer, &Routes.influencer_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_influencer_confirmation_instructions(
        %Influencer{} = influencer,
        confirmation_url_fun
      )
      when is_function(confirmation_url_fun, 1) do
    if influencer.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, influencer_token} = InfluencerToken.build_email_token(influencer, "confirm")
      Repo.insert!(influencer_token)

      InfluencerNotifier.deliver_confirmation_instructions(
        influencer,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a influencer by the given token.

  If the token matches, the influencer account is marked as confirmed
  and the token is deleted.
  """
  def confirm_influencer(token) do
    with {:ok, query} <- InfluencerToken.verify_email_token_query(token, "confirm"),
         %Influencer{} = influencer <- Repo.one(query),
         {:ok, %{influencer: influencer}} <-
           Repo.transaction(confirm_influencer_multi(influencer)) do
      {:ok, influencer}
    else
      _ -> :error
    end
  end

  defp confirm_influencer_multi(influencer) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:influencer, Influencer.confirm_changeset(influencer))
    |> Ecto.Multi.delete_all(
      :tokens,
      InfluencerToken.influencer_and_contexts_query(influencer, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given influencer.

  ## Examples

      iex> deliver_influencer_reset_password_instructions(influencer, &Routes.influencer_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_influencer_reset_password_instructions(
        %Influencer{} = influencer,
        reset_password_url_fun
      )
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, influencer_token} =
      InfluencerToken.build_email_token(influencer, "reset_password")

    Repo.insert!(influencer_token)

    InfluencerNotifier.deliver_reset_password_instructions(
      influencer,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the influencer by reset password token.

  ## Examples

      iex> get_influencer_by_reset_password_token("validtoken")
      %Influencer{}

      iex> get_influencer_by_reset_password_token("invalidtoken")
      nil

  """
  def get_influencer_by_reset_password_token(token) do
    with {:ok, query} <- InfluencerToken.verify_email_token_query(token, "reset_password"),
         %Influencer{} = influencer <- Repo.one(query) do
      influencer
    else
      _ -> nil
    end
  end

  @doc """
  Resets the influencer password.

  ## Examples

      iex> reset_influencer_password(influencer, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Influencer{}}

      iex> reset_influencer_password(influencer, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_influencer_password(influencer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:influencer, Influencer.password_changeset(influencer, attrs))
    |> Ecto.Multi.delete_all(
      :tokens,
      InfluencerToken.influencer_and_contexts_query(influencer, :all)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{influencer: influencer}} -> {:ok, influencer}
      {:error, :influencer, changeset, _} -> {:error, changeset}
    end
  end
end
