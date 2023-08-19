defmodule AllThingsSocialWeb.BrandConfirmationController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Brands

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"brand" => %{"email" => email}}) do
    if brand = Brands.get_brand_by_email(email) do
      Brands.deliver_brand_confirmation_instructions(
        brand,
        &Routes.brand_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the brand after confirmation to avoid a
  # leaked token giving the brand access to the account.
  def update(conn, %{"token" => token}) do
    case Brands.confirm_brand(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Brand confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current brand and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the brand themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_brand: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Brand confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
