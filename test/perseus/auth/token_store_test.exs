defmodule Perseus.Auth.TokenStoreTest do
  use Perseus.DataCase

  alias Perseus.Auth.TokenStore
  alias Perseus.Auth.UserToken

  import Perseus.AccountsFixtures

  @magic_link_table :magic_link_tokens
  @signup_table :signup_tokens
  @session_table :session_tokens

  setup do
    # Create an ETS table for testing purposes
    init_table(@magic_link_table)
    init_table(@session_table)
    :ok
  end

  describe "store_magic_link_token/3" do
    setup do
      {_, token} = UserToken.build_token()
      email = "test@example.com"
      ttl = 10
      {:ok, %{token: token, email: email, ttl: ttl}}
    end

    test "stores magic link token correctly", %{token: token, email: email, ttl: ttl} do
      TokenStore.store_magic_link_token(token, email, ttl)

      assert [{^token, ^email, _}] = :ets.lookup(@magic_link_table, token)
    end
  end

  describe "store_signup_token/3" do
    setup do
      {_, token} = UserToken.build_token()
      email = "test@example.com"
      ttl = 10
      {:ok, %{token: token, email: email, ttl: ttl}}
    end

    test "stores sign up token correctly", %{token: token, email: email, ttl: ttl} do
      TokenStore.store_signup_token(token, email, ttl)

      assert [{^token, ^email, _}] = :ets.lookup(@signup_table, token)
    end
  end

  describe "store_session_token/3" do
    setup do
      {_, token} = UserToken.build_token()
      user = user_fixture()
      ttl = 10
      {:ok, %{token: token, user: user, ttl: ttl}}
    end

    test "stores session token correctly", %{token: token, user: user, ttl: ttl} do
      TokenStore.store_signup_token(token, user, ttl)

      assert [{^token, ^user, _}] = :ets.lookup(@signup_table, token)
    end
  end

  defp init_table(table) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:set, :public, :named_table, read_concurrency: true])
    end
  end
end
