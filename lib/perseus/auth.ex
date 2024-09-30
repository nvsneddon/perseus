defmodule Perseus.Auth do
  alias Perseus.Accounts
  alias Perseus.Accounts.UserNotifier
  alias Perseus.Auth.UserToken
  alias Perseus.Auth.TokenStore
  alias Perseus.Utils.BinaryUtils

  @magic_link_token_ttl 60 * 15
  @signup_token_ttl 60 * 15
  @session_token_ttl 60 * 60

  def send_login_email(email, url_fun \\ nil) do
    with {:ok, _} <- Accounts.get_user_by_email(email),
         {:ok, token} <- generate_login_token(email),
         encoded_token <- BinaryUtils.encode(token) do
      if url_fun do
        UserNotifier.deliver_login_link(email, url_fun.(encoded_token))
      else
        {:ok, encoded_token}
      end
    else
      _ -> :error
    end
  end

  def send_signup_email(email, url_fun \\ nil) do
    with {:ok, token} <- generate_signup_token(email),
         encoded_token <- BinaryUtils.encode(token) do
      if url_fun do
        UserNotifier.deliver_signup_link(email, url_fun.(encoded_token))
      else
        {:ok, encoded_token}
      end
    else
      _ -> :error
    end
  end

  def login_user_by_email(email) do
    case Accounts.get_user_by_email(email) do
      {:ok, user} -> generate_session_token(user)
      _ -> {:error, "User not found"}
    end
  end

  def find_email(:magic_link, token) do
    token
    |> UserToken.hash()
    |> TokenStore.validate_magic_link_token()
  end

  def find_email(:signup, token) do
    token
    |> UserToken.hash()
    |> TokenStore.validate_signup_token()
  end

  def find_user(token) do
    token
    |> UserToken.hash()
    |> TokenStore.validate_session_token()
  end

  defp generate_login_token(email) do
    {token, hashed_token} = UserToken.build_token()
    TokenStore.store_magic_link_token(hashed_token, email, @magic_link_token_ttl)
    {:ok, token}
  end

  defp generate_signup_token(email) do
    {token, hashed_token} = UserToken.build_token()
    TokenStore.store_signup_token(hashed_token, email, @signup_token_ttl)
    {:ok, token}
  end

  defp generate_session_token(profile) do
    {token, hashed_token} = UserToken.build_token()
    TokenStore.store_session_token(hashed_token, profile, @session_token_ttl)
    {:ok, token}
  end
end
