defmodule PerseusWeb.Router do
  use PerseusWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug PerseusWeb.Plugs.AuthenticateUser
  end

  scope "/api" do
    pipe_through :api
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: PerseusWeb.Schema

    forward "/", Absinthe.Plug, schema: PerseusWeb.Schema
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:perseus, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
