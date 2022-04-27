defmodule RemoteWeb.Router do
  use RemoteWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RemoteWeb do
    pipe_through :api

    get "/", UserController, :fetch_users
  end
end
