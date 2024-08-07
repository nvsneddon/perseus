defmodule PerseusWeb.Resolvers.Auth do
  alias Perseus.Accounts

  def get_login_token(_parent, _args, _resolution) do
    {:ok, %{}}
  end

  def send_magic_link(_parent, %{email: email}, _resolution) do
    case Accounts.send_login_email(email, &("localhost:3000/login/#{&1}")) do
      :ok -> {:ok, true}
      :error -> {:ok, false}
    end
  end

  def login_user(_parent, %{token: token}, _resolution) do
    case Accounts.login_user_by_login_token(token) do
      {:ok, session_token} -> {:ok, %{session_token: session_token}}
      {:error, msg} -> {:error, msg}
    end
  end 
end
