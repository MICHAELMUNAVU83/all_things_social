defmodule AllThingsSocialWeb.Router do
  use AllThingsSocialWeb, :router

  import AllThingsSocialWeb.BrandAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AllThingsSocialWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_brand
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AllThingsSocialWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AllThingsSocialWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AllThingsSocialWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :redirect_if_brand_is_authenticated]

    get "/brands/register", BrandRegistrationController, :new
    post "/brands/register", BrandRegistrationController, :create
    get "/brands/log_in", BrandSessionController, :new
    post "/brands/log_in", BrandSessionController, :create
    get "/brands/reset_password", BrandResetPasswordController, :new
    post "/brands/reset_password", BrandResetPasswordController, :create
    get "/brands/reset_password/:token", BrandResetPasswordController, :edit
    put "/brands/reset_password/:token", BrandResetPasswordController, :update
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :require_authenticated_brand]

    get "/brands/settings", BrandSettingsController, :edit
    put "/brands/settings", BrandSettingsController, :update
    get "/brands/settings/confirm_email/:token", BrandSettingsController, :confirm_email
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser]

    delete "/brands/log_out", BrandSessionController, :delete
    get "/brands/confirm", BrandConfirmationController, :new
    post "/brands/confirm", BrandConfirmationController, :create
    get "/brands/confirm/:token", BrandConfirmationController, :edit
    post "/brands/confirm/:token", BrandConfirmationController, :update
  end
end
