defmodule PerseusWeb.Schema.Mutations.AuthMutationsTest do
  alias Perseus.Utils.BinaryUtils
  alias Perseus.Auth
  use PerseusWeb.ConnCase, async: true

  import Perseus.AccountsFixtures

  # Define the query that you will be testing
  @login_query """
  mutation startSession {
    logIn {
      sessionToken
    }
  }
  """

  describe "login mutation" do
    setup do
      user = user_fixture()
      {:ok, token} = Auth.send_login_email(user.email)
      %{user: user, token: token}
    end

    test "should login when email is found", %{conn: conn, user: user, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "MagicLink " <> token)
        |> put_req_header("x-custom-header", "custom-value")
        |> post("/api/graphql", %{query: @login_query})

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)["data"]

      assert %{
               "logIn" => %{
                 "sessionToken" => session_token
               }
             } = response_data

      {:ok, decoded_session_token} = BinaryUtils.decode(session_token)
      assert {:ok, ^user} = Auth.find_user(decoded_session_token)
    end
  end
end
