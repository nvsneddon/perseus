defmodule PerseusWeb.Plugs.AuthenticateUserTest do
  use PerseusWeb.ConnCase, async: true
  import Perseus.AccountsFixtures

  alias Perseus.Utils.BinaryUtils
  alias PerseusWeb.Plugs.AuthenticateUser

  describe "session token" do
    setup do
      # Here you can mock Auth or BinaryUtils as needed
      user = user_fixture()
      {:ok, valid_token} = Perseus.Auth.login_user_by_email(user.email)
      %{user: user, token: BinaryUtils.encode(valid_token)}
    end

    test "adds context with user for valid session token", %{conn: conn, token: token, user: user} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> AuthenticateUser.call(%{})

      # Verify that the context was added correctly
      context = conn.private.absinthe.context
      assert context[:user] == user
      assert context[:token_type] == :session
    end

    test "returns error for invalid authorization header", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalidtoken}")
        |> AuthenticateUser.call(%{})

      # Check that an error is returned
      context = conn.private.absinthe.context
      assert context[:error] == "Authorization header invalid"
    end
  end

  describe "login token" do
    setup do
      user = user_fixture()
      {:ok, token} = Perseus.Auth.send_login_email(user.email)
      %{user: user, token: token}
    end

    test "adds context with email for valid login token", %{conn: conn, user: user, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "MagicLink #{token}")
        |> AuthenticateUser.call(%{})

      # Verify that the context was added correctly
      context = conn.private.absinthe.context
      assert context[:email] == user.email
      assert context[:token_type] == :magic_link
    end
  end

  describe "signup token" do
    setup do
      email = unique_user_email()
      {:ok, token} = Perseus.Auth.send_signup_email(email)
      %{email: email, token: token}
    end

    test "adds context with email for valid signup token", %{
      conn: conn,
      email: email,
      token: token
    } do
      conn =
        conn
        |> put_req_header("authorization", "Signup #{token}")
        |> AuthenticateUser.call(%{})

      # Verify that the context was added correctly
      context = conn.private.absinthe.context
      assert context[:email] == email
      assert context[:token_type] == :signup
    end
  end

  test "returns normal conn when no authorization header is present", %{conn: conn} do
    conn = AuthenticateUser.call(conn, %{})

    context = conn.private.absinthe.context
    assert context == %{}
  end

  test "returns error for invalid authorization header", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Invalid token}")
      |> AuthenticateUser.call(%{})

    # Check that an error is returned
    context = conn.private.absinthe.context
    assert context[:error] == "Authorization header invalid"
  end
end
