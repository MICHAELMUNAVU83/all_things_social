defmodule AllThingsSocialWeb.BrandSessionController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Brands
  alias AllThingsSocialWeb.BrandAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"brand" => brand_params}) do
    %{"email" => email, "password" => password} = brand_params

    if brand = Brands.get_brand_by_email_and_password(email, password) do
      BrandAuth.log_in_brand(conn, brand, brand_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> BrandAuth.log_out_brand()
  end
end
