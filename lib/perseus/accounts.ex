defmodule Perseus.Accounts do
  alias Perseus.Accounts.UserToken
  alias Perseus.Accounts.UserNotifier
  alias Perseus.Redis

  @login_prefix "login:"
  @session_prefix "session:"

  @login_token_ttl 60 * 15
  @session_token_ttl 60 * 60

  def send_login_email(email, url_fun) do
    with {:ok, token} <- generate_login_token(email),
         {:ok, _} <- UserNotifier.deliver_magic_link(email, url_fun.(token)) do
      :ok
    else
      _ -> :error
    end
  end

  def generate_login_token(email) do
    generate_token(email, @login_prefix, @login_token_ttl)
  end

  defp generate_session_token(email) do
    generate_token(email, @session_prefix, @session_token_ttl)
  end

  defp generate_token(email, prefix, exp) do
    {token, hashed_token} = UserToken.build_token()

    case Redis.set(prefix <> hashed_token, email, exp) do
      {:ok, _} -> {:ok, token}
      error -> error
    end
  end

  def get_email_by_login_token(token) do
    get_email_by_token(token, @login_prefix)
  end

  def get_email_by_session_token(token) do
    get_email_by_token(token, @session_prefix)
  end

  defp get_email_by_token(token, prefix) do
    {:ok, hashed_token} = UserToken.get_encoded_hash(token)
    Redis.get(prefix <> hashed_token)
  end

  def login_user_by_email_and_login_token(email, token) do
    {:ok, expected_email} = get_email_by_login_token(token)
    {:ok, hashed_token} = UserToken.get_encoded_hash(token)

    if email == expected_email do
      with {:ok, _} <- Redis.del(@login_prefix <> hashed_token),
           {:ok, token} <- generate_session_token(email) do
        {:ok, token}
      else
        _ -> {:error, "Redis error"}
      end
    else
      {:error, "Unauthorized"}
    end
  end
end
