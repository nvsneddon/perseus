defmodule PerseusWeb.Plugs.AuthenticateUser do
  import Plug.Conn

  alias Perseus.Accounts
  alias Perseus.Utils.BinaryUtils

  def init(opts), do: opts

  def call(conn, _opts) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    with token when not is_nil(token) <- get_auth_token(conn),
         {:ok, user} <- Accounts.get_email_by_session_token(token) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end

  defp get_auth_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, decoded_token} <- BinaryUtils.decode(token) do
      decoded_token
    else
      _ -> nil
    end
  end
end
