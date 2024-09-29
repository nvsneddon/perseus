defmodule PerseusWeb.Schema.Mutations.AuthMutations do
  use Absinthe.Schema.Notation

  alias PerseusWeb.Resolvers

  object :auth_mutations do
    field :send_login_link, :boolean do
      arg :email, non_null(:string)

      resolve &Resolvers.Auth.send_login_link/3
    end

    field :send_signup_link, :boolean do
      arg :email, non_null(:string)

      resolve &Resolvers.Auth.send_signup_link/3
    end

    field :log_in, :session do
      middleware PerseusWeb.Middleware.RequireAuth, :magic_link

      resolve &Resolvers.Auth.login_user/3
    end

    field :sign_up, :sign_up_response do
      arg :user, :user_input
      middleware PerseusWeb.Middleware.RequireAuth, :magic_link

      resolve &Resolvers.Auth.signup_user/3
    end
  end
end
