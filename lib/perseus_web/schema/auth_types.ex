defmodule PerseusWeb.Schema.AuthTypes do
  use Absinthe.Schema.Notation

  object :session do
    field :session_token, :string
  end

  object :login do
    field :token, :string
  end
end
