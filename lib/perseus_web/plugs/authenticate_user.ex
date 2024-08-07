defmodule PerseusWeb.Plugs.AuthenticateUser do
  import Plug.Conn

  alias Perseus.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    case get_auth_token(conn) do
      nil ->
        %{}

      token ->
        case Accounts.get_email_by_session_token(token) do
          {:ok, user} ->
            %{current_user: user}

          _ ->
            %{}
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
