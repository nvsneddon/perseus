defmodule Perseus.Accounts do
  alias Perseus.Accounts.UserToken
  alias Perseus.Accounts.UserNotifier
  alias Perseus.Accounts.TokenStore
  alias Perseus.Utils.BinaryUtils

  @magic_link_token_ttl 60 * 15
  @session_token_ttl 60 * 60

  def send_login_email(email, url_fun) do
    with {:ok, token} <- generate_login_token(email),
         encoded_token <- BinaryUtils.encode(token),
         {:ok, _} <- UserNotifier.deliver_magic_link(email, url_fun.(encoded_token)) do
      :ok
    else
      _ -> :error
    end
  end

  def login_user_by_login_token(token) do
    with {:ok, email} <- get_email_by_login_token(token),
         {:ok, session_token} <- generate_session_token(email) do
      {:ok, session_token}
    else
      {:error, :expired_token} ->
        {:error, "Expired token"}

      {:error, :not_found} ->
        {:error, "Not found"}

      _ ->
        {:error, "Token store Error"}
    end
  end

  def generate_login_token(email) do
    {token, hashed_token} = UserToken.build_token()
    TokenStore.store_token(:magic_link, hashed_token, email, @magic_link_token_ttl)
    {:ok, token}
  end

  defp generate_session_token(email) do
    {token, hashed_token} = UserToken.build_token()
    TokenStore.store_token(:session, hashed_token, email, @session_token_ttl)
    {:ok, token}
  end

  def get_email_by_login_token(token) do
    token
    |> UserToken.hash()
    |> TokenStore.validate_magic_link_token()
  end

  def get_email_by_session_token(token) do
    token
    |> UserToken.hash()
    |> TokenStore.validate_session_token()
  end
end
