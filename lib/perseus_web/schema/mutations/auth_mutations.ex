defmodule PerseusWeb.Schema.Mutations.AuthMutations do
  use Absinthe.Schema.Notation

  alias PerseusWeb.Resolvers

  object :auth_mutations do
    field :send_magic_link, :boolean do
      arg :email, non_null(:string)

      resolve &Resolvers.Auth.send_magic_link/3
    end

    field :log_in, :session do
      middleware(PerseusWeb.Middleware.RequireAuth, %{token_type: :magic_link})

      resolve &Resolvers.Auth.login_user/3
    end
  end
end
