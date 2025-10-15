defmodule AtomicWordsWeb.Router do
  use AtomicWordsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AtomicWordsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AtomicWordsWeb do
    pipe_through :browser

    get "/onboarding", AuthController, :onboarding
    get "/login", AuthController, :login
    get "/sign_up", AuthController, :sign_up
    post "/logout", AuthController, :logout
    get "/", PageController, :home
    get "/words", WordsController, :index
    get "/word_details", WordsController, :word_details
    get "/practice", WordsController, :practice
    get "/stats", StatsController, :stats
    get "/settings", SettingsController, :settings
  end

  # Other scopes may use custom stacks.
  # scope "/api", AtomicWordsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:atomic_words, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AtomicWordsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
