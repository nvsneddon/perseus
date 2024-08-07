defmodule PerseusWeb.Schema do
  use Absinthe.Schema
  import_types PerseusWeb.Schema.AuthTypes

  alias PerseusWeb.Resolvers

  query do
    field :get_session, non_null(:session) do
      resolve &Resolvers.Auth.get_login_token/3
    end

    field :get_user, non_null(:string) do
      middleware(PerseusWeb.Middleware.RequireAuth)

      resolve fn _, _, %{context: %{current_user: user}} ->
        {:ok, user}
      end
    end
  end

  mutation do
    field :send_magic_link, :boolean do
      arg :email, non_null(:string)

      resolve &Resolvers.Auth.send_magic_link/3
    end

    field :log_in, :session do
      arg :token, non_null(:string)

      resolve &Resolvers.Auth.login_user/3
    end
  end
end
