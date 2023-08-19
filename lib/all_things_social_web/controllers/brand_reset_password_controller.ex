defmodule AllThingsSocialWeb.BrandResetPasswordController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Brands

  plug :get_brand_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"brand" => %{"email" => email}}) do
    if brand = Brands.get_brand_by_email(email) do
      Brands.deliver_brand_reset_password_instructions(
        brand,
        &Routes.brand_reset_password_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Brands.change_brand_password(conn.assigns.brand))
  end

  # Do not log in the brand after reset password to avoid a
  # leaked token giving the brand access to the account.
  def update(conn, %{"brand" => brand_params}) do
    case Brands.reset_brand_password(conn.assigns.brand, brand_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.brand_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_brand_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if brand = Brands.get_brand_by_reset_password_token(token) do
      conn |> assign(:brand, brand) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
