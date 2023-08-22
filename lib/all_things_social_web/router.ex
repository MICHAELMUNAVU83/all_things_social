defmodule AllThingsSocialWeb.Router do
  use AllThingsSocialWeb, :router

  import AllThingsSocialWeb.InfluencerAuth

  import AllThingsSocialWeb.BrandAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AllThingsSocialWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_influencer
    plug :fetch_current_brand
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AllThingsSocialWeb do
    pipe_through :browser

    live "/", PageLive.Index, :index

    live "/chats", ChatLive.Index, :index
    live "/chats/new", ChatLive.Index, :new
    live "/chats/:id/edit", ChatLive.Index, :edit

    live "/chats/:id", ChatLive.Show, :show
    live "/chats/:id/show/edit", ChatLive.Show, :edit

    live "/payments", PaymentLive.Index, :index
    live "/payments/new", PaymentLive.Index, :new
    live "/payments/:id/edit", PaymentLive.Index, :edit

    live "/payments/:id", PaymentLive.Show, :show
    live "/payments/:id/show/edit", PaymentLive.Show, :edit
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :redirect_if_brand_is_authenticated]

    live "/content_boards", ContentBoardLive.Index, :index
    live "/content_boards/new", ContentBoardLive.Index, :new
    live "/content_boards/:id/edit", ContentBoardLive.Index, :edit

    live "/content_boards/:id", ContentBoardLive.Show, :show
    live "/content_boards/:id/show/edit", ContentBoardLive.Show, :edit

    live "/influencer_accounts", InfluencerAccountLive.Index, :index
    live "/influencer_accounts/new", InfluencerAccountLive.Index, :new

    live "/influencer_accounts/:id", InfluencerAccountLive.Show, :show
    live "/influencer_accounts/:id/show/edit", InfluencerAccountLive.Show, :edit

    live "/tasks", TaskLive.Index, :index
    live "/tasks/new", TaskLive.Index, :new
    live "/tasks/:id/edit", TaskLive.Index, :edit

    live "/tasks/:id", TaskLive.Show, :show
    live "/tasks/:id/show/edit", TaskLive.Show, :edit

    live "/all_influencers", AllInfluencersLive.Index, :index

    live "/my_influencers", MyInfluencersLive.Index, :index
    live "/my_influencers/:id", MyInfluencersLive.Show, :show
    live "/my_influencers/:id/add_task", MyInfluencersLive.Show, :add_task
    live "/my_influencers/:id/:task_id/edit_task", MyInfluencersLive.Show, :edit_task

    live "/all_influencers/:id", AllInfluencersLive.Index, :show

    live "/all_influencers/:id/add_influencer_account",
         AllInfluencersLive.Index,
         :add_influencer_account

    live "/influencer_accounts/:id/:influencer_account_id/edit",
         ContentBoardLive.Show,
         :editinfluenceraccount
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :redirect_if_influencer_is_authenticated]

    live "/influencer_dashboard", InfluencerDashboardLive.Index, :index

    live "/influencer_dashboard/add_social_media_account",
         InfluencerDashboardLive.Index,
         :add_social_media_account

    live "/influencer_dashboard/add_rate", InfluencerDashboardLive.Index, :add_rate
    live "/influencer_dashboard/add_niche", InfluencerDashboardLive.Index, :add_niche
    live "/influencer_dashboard/:niche_id/edit_niche", InfluencerDashboardLive.Index, :edit_niche
    live "/influencer_dashboard/:rate_id/edit_rate", InfluencerDashboardLive.Index, :edit_rate

    live "/influencer_dashboard/:influencer_account/chat",
         InfluencerDashboardLive.Index,
         :chat

    live "/influencer_dashboard/:social_media_account_id/edit_social_media_account",
         InfluencerDashboardLive.Index,
         :edit_social_media_account

    live "/niches", NicheLive.Index, :index
    live "/niches/new", NicheLive.Index, :new
    live "/niches/:id/edit", NicheLive.Index, :edit

    live "/niches/:id", NicheLive.Show, :show
    live "/niches/:id/show/edit", NicheLive.Show, :edit

    live "/social_media_accounts", SocialMediaAccountLive.Index, :index
    live "/social_media_accounts/new", SocialMediaAccountLive.Index, :new
    live "/social_media_accounts/:id/edit", SocialMediaAccountLive.Index, :edit
    live "/social_media_accounts/:id", SocialMediaAccountLive.Show, :show
    live "/social_media_accounts/:id/show/edit", SocialMediaAccountLive.Show, :edit

    live "/rates", RateLive.Index, :index
    live "/rates/new", RateLive.Index, :new
    live "/rates/:id/edit", RateLive.Index, :edit

    live "/rates/:id", RateLive.Show, :show
    live "/rates/:id/show/edit", RateLive.Show, :edit
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

  ## Authentication routes

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :redirect_if_influencer_is_authenticated]

    get "/influencers/register", InfluencerRegistrationController, :new
    post "/influencers/register", InfluencerRegistrationController, :create
    get "/influencers/log_in", InfluencerSessionController, :new
    post "/influencers/log_in", InfluencerSessionController, :create
    get "/influencers/reset_password", InfluencerResetPasswordController, :new
    post "/influencers/reset_password", InfluencerResetPasswordController, :create
    get "/influencers/reset_password/:token", InfluencerResetPasswordController, :edit
    put "/influencers/reset_password/:token", InfluencerResetPasswordController, :update
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser, :require_authenticated_influencer]

    get "/influencers/settings", InfluencerSettingsController, :edit
    put "/influencers/settings", InfluencerSettingsController, :update
    get "/influencers/settings/confirm_email/:token", InfluencerSettingsController, :confirm_email
  end

  scope "/", AllThingsSocialWeb do
    pipe_through [:browser]

    delete "/influencers/log_out", InfluencerSessionController, :delete
    get "/influencers/confirm", InfluencerConfirmationController, :new
    post "/influencers/confirm", InfluencerConfirmationController, :create
    get "/influencers/confirm/:token", InfluencerConfirmationController, :edit
    post "/influencers/confirm/:token", InfluencerConfirmationController, :update
  end
end
