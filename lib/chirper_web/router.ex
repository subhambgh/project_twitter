defmodule ChirperWeb.Router do
  use ChirperWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChirperWeb do
    pipe_through [:browser,ChirperWeb.Plugs.Guest]

    resources "/register", UserController, only: [:create, :new]
    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end


  scope "/", ChirperWeb do
    pipe_through [:browser,ChirperWeb.Plugs.Auth,:put_user_token]

    resources "/", PostController, only: [:create, :index]
    get "/retweet", PostController, :retweet
    resources "/users", UserController, only: [:index, :create, :new, :show] do
      post "/follow", RelationshipController, :follow
      post "/unfollow", RelationshipController, :unfollow
    end
    #get "/followers", FollowerController, :followers
    #get "/following", FollowerController, :following
    delete "/logout", SessionController, :delete
    get "/*path", ErrorController, :index
  end

  defp put_user_token(conn, _) do
    if current_user = get_session(conn,:current_user_id) do
      # this is a very tricky method
      time = :rand.uniform(10000000000000000000)
      token = Phoenix.Token.sign(conn, "user socket", {current_user, time})
      conn
      |> assign(:user_token, token)
      |> assign(:user_id, current_user)
    else
      conn
    end
  end
  # Other scopes may use custom stacks.
  # scope "/api", ChirperWeb do
  #   pipe_through :api
  # end
end
