defmodule PerseusWeb.Resolvers.Auth do
  alias Perseus.Auth

  def get_login_token(_parent, _args, _resolution) do
    {:ok, %{}}
  end

  def send_magic_link(_parent, %{email: email}, _resolution) do
    case Auth.send_login_email(email, &"localhost:3000/login/#{&1}") do
      :ok -> {:ok, true}
      :error -> {:ok, false}
    end
  end

  def login_user(_parent, _args, %{context: %{email: email, token_type: :magic_link}}) do
    case Auth.login_user_by_email(email) do
      {:ok, session_token} -> {:ok, %{session_token: session_token}}
      {:error, msg} -> {:error, msg}
    end
  end
end
