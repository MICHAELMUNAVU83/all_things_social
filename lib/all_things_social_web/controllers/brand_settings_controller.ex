defmodule AllThingsSocialWeb.BrandSettingsController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Brands
  alias AllThingsSocialWeb.BrandAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "brand" => brand_params} = params
    brand = conn.assigns.current_brand

    case Brands.apply_brand_email(brand, password, brand_params) do
      {:ok, applied_brand} ->
        Brands.deliver_update_email_instructions(
          applied_brand,
          brand.email,
          &Routes.brand_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.brand_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "brand" => brand_params} = params
    brand = conn.assigns.current_brand

    case Brands.update_brand_password(brand, password, brand_params) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:brand_return_to, Routes.brand_settings_path(conn, :edit))
        |> BrandAuth.log_in_brand(brand)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Brands.update_brand_email(conn.assigns.current_brand, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.brand_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.brand_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    brand = conn.assigns.current_brand

    conn
    |> assign(:email_changeset, Brands.change_brand_email(brand))
    |> assign(:password_changeset, Brands.change_brand_password(brand))
  end
end
