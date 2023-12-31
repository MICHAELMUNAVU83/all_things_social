defmodule AllThingsSocialWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AllThingsSocialWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AllThingsSocialWeb.ConnCase

      alias AllThingsSocialWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint AllThingsSocialWeb.Endpoint
    end
  end

  setup tags do
    AllThingsSocial.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in brands.

      setup :register_and_log_in_brand

  It stores an updated connection and a registered brand in the
  test context.
  """
  def register_and_log_in_brand(%{conn: conn}) do
    brand = AllThingsSocial.BrandsFixtures.brand_fixture()
    %{conn: log_in_brand(conn, brand), brand: brand}
  end

  @doc """
  Logs the given `brand` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_brand(conn, brand) do
    token = AllThingsSocial.Brands.generate_brand_session_token(brand)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:brand_token, token)
  end

  @doc """
  Setup helper that registers and logs in influencers.

      setup :register_and_log_in_influencer

  It stores an updated connection and a registered influencer in the
  test context.
  """
  def register_and_log_in_influencer(%{conn: conn}) do
    influencer = AllThingsSocial.InfluencersFixtures.influencer_fixture()
    %{conn: log_in_influencer(conn, influencer), influencer: influencer}
  end

  @doc """
  Logs the given `influencer` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_influencer(conn, influencer) do
    token = AllThingsSocial.Influencers.generate_influencer_session_token(influencer)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:influencer_token, token)
  end
end
