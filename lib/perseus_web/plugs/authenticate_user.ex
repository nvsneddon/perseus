defmodule PerseusWeb.Plugs.AuthenticateUser do
  import Plug.Conn

  alias Perseus.Auth
  alias Perseus.Utils.BinaryUtils

  def init(opts), do: opts

  def call(conn, _opts) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    case get_auth_token(conn) do
      {:ok, token_type, token} -> build_context_from_token(token, token_type)
      _ -> %{}
    end
  end

  defp build_context_from_token(token, token_type) do
    case find_user_or_email(token_type, token) do
      {:ok, result} -> Map.put(result, :token_type, token_type)
      {:error, message} -> %{error: message}
    end
  end

  # Refactor find_user_or_email to handle all token types
  defp find_user_or_email(token_type, token) do
    case fetch_auth_data(token_type, token) do
      {:ok, data} -> {:ok, wrap_data(token_type, data)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_auth_data(:magic_link, token), do: Auth.find_email(:magic_link, token)
  defp fetch_auth_data(:signup, token), do: Auth.find_email(:signup, token)
  defp fetch_auth_data(:session, token), do: Auth.find_user(token)

  defp wrap_data(:magic_link, email), do: %{email: email}
  defp wrap_data(:signup, email), do: %{email: email}
  defp wrap_data(:session, user), do: %{user: user}

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> decode_token(:session, token)
      ["MagicLink " <> token] -> decode_token(:magic_link, token)
      ["Signup " <> token] -> decode_token(:signup, token)
      _ -> {:error, :invalid_token}
    end
  end

  defp decode_token(token_type, token) do
    case BinaryUtils.decode(token) do
      {:ok, decoded_token} -> {:ok, token_type, decoded_token}
      _ -> {:error, :invalid_token}
    end
  end
end
