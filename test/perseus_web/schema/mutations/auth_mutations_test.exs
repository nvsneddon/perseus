defmodule PerseusWeb.Schema.Mutations.AuthMutationsTest do
  alias Perseus.Utils.BinaryUtils
  alias Perseus.Auth
  use PerseusWeb.ConnCase, async: true

  import Perseus.AccountsFixtures

  # Define the query that you will be testing

  describe "login mutation" do
    setup do
      query = """
        mutation startSession {
          logIn {
            sessionToken
          }
        }
      """

      user = user_fixture()
      {:ok, token} = Auth.send_login_email(user.email)
      %{user: user, token: token, query: query}
    end

    test "should login when email is found", %{conn: conn, user: user, token: token, query: query} do
      conn =
        conn
        |> put_req_header("authorization", "MagicLink " <> token)
        |> post("/api/graphql", %{query: query})

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

    test "should not resolve if token is misconfigured", %{conn: conn, query: query} do
      conn =
        conn
        |> put_req_header("authorization", "MagicLink " <> "invalidtoken")
        |> post("/api/graphql", %{query: query})

      assert json_response(conn, 200)
      errors = json_response(conn, 200)["errors"]

      assert [%{"code" => "UNAUTHENTICATED", "message" => "not_found"}] = errors
    end

    test "should only allow magic link tokens", %{conn: conn, query: query, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post("/api/graphql", %{query: query})

      assert json_response(conn, 200)
      errors = json_response(conn, 200)["errors"]

      assert [%{"code" => "UNAUTHENTICATED", "message" => "not_found"}] = errors
    end
  end

  describe "sendLoginLink mutation" do
    import Swoosh.TestAssertions

    setup do
      query = """
        mutation($email: String!) {
          sendLoginLink(email: $email)
        }
      """

      user = user_fixture()
      %{query: query, user: user}
    end

    test "should send an email when email is found and return true", %{
      conn: conn,
      query: query,
      user: user
    } do
      variables = %{"email" => user.email}
      conn = post(conn, "/api/graphql", %{query: query, variables: variables})

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)["data"]

      assert %{"sendLoginLink" => true} = response_data

      assert_email_sent(fn email ->
        [{_, delivered_to}] = email.to
        assert delivered_to == user.email
      end)
    end

    test "should not send an email when email is found and still return true", %{
      conn: conn,
      query: query
    } do
      variables = %{"email" => "invalid@example.com"}
      conn = post(conn, "/api/graphql", %{query: query, variables: variables})

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)["data"]

      assert %{"sendLoginLink" => true} = response_data
      assert_no_email_sent()
    end
  end

  describe "sendSignupLink mutation" do
    import Swoosh.TestAssertions

    setup do
      query = """
        mutation ($email: String!) {
          sendSignupLink(email: $email)
        }
      """

      %{query: query}
    end

    test "should send an email to sign up", %{conn: conn, query: query} do
      email_address = "new.email@example.com"
      variables = %{"email" => email_address}
      conn = post(conn, "/api/graphql", %{query: query, variables: variables})

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)["data"]

      assert %{"sendSignupLink" => true} = response_data

      assert_email_sent(fn email ->
        [{_, delivered_to}] = email.to
        assert delivered_to == email_address
      end)
    end
  end
end
