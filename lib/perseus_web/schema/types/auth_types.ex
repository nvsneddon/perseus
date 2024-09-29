defmodule PerseusWeb.Schema.Types.AuthTypes do
  use Absinthe.Schema.Notation

  object :session do
    field :session_token, :binary
  end

  object :login do
    field :token, :binary
  end
end
