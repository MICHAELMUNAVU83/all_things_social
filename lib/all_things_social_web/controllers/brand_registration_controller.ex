defmodule AllThingsSocialWeb.BrandRegistrationController do
  use AllThingsSocialWeb, :controller

  alias AllThingsSocial.Brands
  alias AllThingsSocial.Brands.Brand
  alias AllThingsSocialWeb.BrandAuth

  def new(conn, _params) do
    changeset = Brands.change_brand_registration(%Brand{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"brand" => brand_params}) do
    case Brands.register_brand(brand_params) do
      {:ok, brand} ->
        {:ok, _} =
          Brands.deliver_brand_confirmation_instructions(
            brand,
            &Routes.brand_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Brand created successfully.")
        |> BrandAuth.log_in_brand(brand)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
