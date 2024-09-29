defmodule PerseusWeb.Schema do
  use Absinthe.Schema

  import_types PerseusWeb.Schema.Types.AuthTypes
  import_types PerseusWeb.Schema.Types.Binary
  import_types PerseusWeb.Schema.Types.UserTypes

  import_types PerseusWeb.Schema.Mutations.AuthMutations

  query do
    field :user, non_null(:user) do
      middleware(PerseusWeb.Middleware.RequireAuth, %{token_type: :session})

      resolve fn _, _, %{context: %{user: user}} ->
        {:ok, user}
      end
    end
  end

  mutation do
    import_fields :auth_mutations
  end
end
