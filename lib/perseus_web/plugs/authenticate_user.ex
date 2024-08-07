defmodule PerseusWeb.Plugs.AuthenticateUser do
  import Plug.Conn

  alias Perseus.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_auth_token(conn) do
      nil ->
        conn

      token ->
        case Accounts.get_email_by_session_token(token) do
          nil ->
            conn

          user ->
            assign(conn, :current_user, user)
        end
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end
