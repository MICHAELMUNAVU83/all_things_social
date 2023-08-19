defmodule AllThingsSocial.Brands do
  @moduledoc """
  The Brands context.
  """

  import Ecto.Query, warn: false
  alias AllThingsSocial.Repo

  alias AllThingsSocial.Brands.{Brand, BrandToken, BrandNotifier}

  ## Database getters

  @doc """
  Gets a brand by email.

  ## Examples

      iex> get_brand_by_email("foo@example.com")
      %Brand{}

      iex> get_brand_by_email("unknown@example.com")
      nil

  """
  def get_brand_by_email(email) when is_binary(email) do
    Repo.get_by(Brand, email: email)
  end

  @doc """
  Gets a brand by email and password.

  ## Examples

      iex> get_brand_by_email_and_password("foo@example.com", "correct_password")
      %Brand{}

      iex> get_brand_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_brand_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    brand = Repo.get_by(Brand, email: email)
    if Brand.valid_password?(brand, password), do: brand
  end

  @doc """
  Gets a single brand.

  Raises `Ecto.NoResultsError` if the Brand does not exist.

  ## Examples

      iex> get_brand!(123)
      %Brand{}

      iex> get_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand!(id), do: Repo.get!(Brand, id)

  ## Brand registration

  @doc """
  Registers a brand.

  ## Examples

      iex> register_brand(%{field: value})
      {:ok, %Brand{}}

      iex> register_brand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_brand(attrs) do
    %Brand{}
    |> Brand.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand changes.

  ## Examples

      iex> change_brand_registration(brand)
      %Ecto.Changeset{data: %Brand{}}

  """
  def change_brand_registration(%Brand{} = brand, attrs \\ %{}) do
    Brand.registration_changeset(brand, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the brand email.

  ## Examples

      iex> change_brand_email(brand)
      %Ecto.Changeset{data: %Brand{}}

  """
  def change_brand_email(brand, attrs \\ %{}) do
    Brand.email_changeset(brand, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_brand_email(brand, "valid password", %{email: ...})
      {:ok, %Brand{}}

      iex> apply_brand_email(brand, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_brand_email(brand, password, attrs) do
    brand
    |> Brand.email_changeset(attrs)
    |> Brand.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the brand email using the given token.

  If the token matches, the brand email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_brand_email(brand, token) do
    context = "change:#{brand.email}"

    with {:ok, query} <- BrandToken.verify_change_email_token_query(token, context),
         %BrandToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(brand_email_multi(brand, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp brand_email_multi(brand, email, context) do
    changeset =
      brand
      |> Brand.email_changeset(%{email: email})
      |> Brand.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:brand, changeset)
    |> Ecto.Multi.delete_all(:tokens, BrandToken.brand_and_contexts_query(brand, [context]))
  end

  @doc """
  Delivers the update email instructions to the given brand.

  ## Examples

      iex> deliver_update_email_instructions(brand, current_email, &Routes.brand_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Brand{} = brand, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, brand_token} = BrandToken.build_email_token(brand, "change:#{current_email}")

    Repo.insert!(brand_token)
    BrandNotifier.deliver_update_email_instructions(brand, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the brand password.

  ## Examples

      iex> change_brand_password(brand)
      %Ecto.Changeset{data: %Brand{}}

  """
  def change_brand_password(brand, attrs \\ %{}) do
    Brand.password_changeset(brand, attrs, hash_password: false)
  end

  @doc """
  Updates the brand password.

  ## Examples

      iex> update_brand_password(brand, "valid password", %{password: ...})
      {:ok, %Brand{}}

      iex> update_brand_password(brand, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand_password(brand, password, attrs) do
    changeset =
      brand
      |> Brand.password_changeset(attrs)
      |> Brand.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:brand, changeset)
    |> Ecto.Multi.delete_all(:tokens, BrandToken.brand_and_contexts_query(brand, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{brand: brand}} -> {:ok, brand}
      {:error, :brand, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_brand_session_token(brand) do
    {token, brand_token} = BrandToken.build_session_token(brand)
    Repo.insert!(brand_token)
    token
  end

  @doc """
  Gets the brand with the given signed token.
  """
  def get_brand_by_session_token(token) do
    {:ok, query} = BrandToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(BrandToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given brand.

  ## Examples

      iex> deliver_brand_confirmation_instructions(brand, &Routes.brand_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_brand_confirmation_instructions(confirmed_brand, &Routes.brand_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_brand_confirmation_instructions(%Brand{} = brand, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if brand.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, brand_token} = BrandToken.build_email_token(brand, "confirm")
      Repo.insert!(brand_token)
      BrandNotifier.deliver_confirmation_instructions(brand, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a brand by the given token.

  If the token matches, the brand account is marked as confirmed
  and the token is deleted.
  """
  def confirm_brand(token) do
    with {:ok, query} <- BrandToken.verify_email_token_query(token, "confirm"),
         %Brand{} = brand <- Repo.one(query),
         {:ok, %{brand: brand}} <- Repo.transaction(confirm_brand_multi(brand)) do
      {:ok, brand}
    else
      _ -> :error
    end
  end

  defp confirm_brand_multi(brand) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:brand, Brand.confirm_changeset(brand))
    |> Ecto.Multi.delete_all(:tokens, BrandToken.brand_and_contexts_query(brand, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given brand.

  ## Examples

      iex> deliver_brand_reset_password_instructions(brand, &Routes.brand_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_brand_reset_password_instructions(%Brand{} = brand, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, brand_token} = BrandToken.build_email_token(brand, "reset_password")
    Repo.insert!(brand_token)
    BrandNotifier.deliver_reset_password_instructions(brand, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the brand by reset password token.

  ## Examples

      iex> get_brand_by_reset_password_token("validtoken")
      %Brand{}

      iex> get_brand_by_reset_password_token("invalidtoken")
      nil

  """
  def get_brand_by_reset_password_token(token) do
    with {:ok, query} <- BrandToken.verify_email_token_query(token, "reset_password"),
         %Brand{} = brand <- Repo.one(query) do
      brand
    else
      _ -> nil
    end
  end

  @doc """
  Resets the brand password.

  ## Examples

      iex> reset_brand_password(brand, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Brand{}}

      iex> reset_brand_password(brand, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_brand_password(brand, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:brand, Brand.password_changeset(brand, attrs))
    |> Ecto.Multi.delete_all(:tokens, BrandToken.brand_and_contexts_query(brand, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{brand: brand}} -> {:ok, brand}
      {:error, :brand, changeset, _} -> {:error, changeset}
    end
  end
end
