defmodule PerseusWeb.Schema.Types.UserTypes do
  use Absinthe.Schema.Notation

  object :sign_up_response do
    field :session, :session
    field :new_user, :user
  end

  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
  end

  input_object :user_input do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
  end
end
