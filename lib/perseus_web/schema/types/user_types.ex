defmodule PerseusWeb.Schema.Types.UserTypes do
  use Absinthe.Schema.Notation

  object :sign_up_response do
    field :session, non_null(:session)
    field :new_user, non_null(:user)
  end

  object :user do
    field :id, non_null(:id)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :email, non_null(:string)
  end

  input_object :user_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :email, non_null(:string)
  end
end
