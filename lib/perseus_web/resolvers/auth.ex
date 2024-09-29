defmodule PerseusWeb.Resolvers.Auth do
  alias Perseus.Auth
  alias Perseus.Accounts

  def get_login_token(_parent, _args, _resolution) do
    {:ok, %{}}
  end

  def send_login_link(_parent, %{email: email}, _resolution) do
    Auth.send_login_email(email, &"localhost:3000/login/#{&1}")
    {:ok, true}
  end

  def send_signup_link(_parent, %{email: email}, _resolution) do
    Auth.send_signup_email(email, &"localhost:3000/signup/#{&1}")
    {:ok, true}
  end

  def login_user(_parent, _args, %{context: %{email: email}}) do
    case Auth.login_user_by_email(email) do
      {:ok, session_token} -> {:ok, %{session_token: session_token}}
      {:error, msg} -> {:error, msg}
    end
  end

  def signup_user(_parent, %{user: user}, %{context: %{email: email}}) do
    with updated_user <- Map.put(user, :email, email),
         {:ok, created_user} <- Accounts.create_user(updated_user),
         {:ok, session_token} <- Auth.login_user_by_email(email) do
      {:ok, %{session: %{session_token: session_token}, new_user: created_user}}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _ -> {:error, "Something went wrong"}
    end
  end
end
