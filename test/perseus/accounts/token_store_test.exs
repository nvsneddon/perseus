defmodule Perseus.Accounts.TokenStoreTest do
  use Perseus.DataCase

  alias Perseus.Accounts.TokenStore
  alias Perseus.Accounts.UserToken

  @magic_link_table :magic_link_tokens
  @session_table :session_tokens

  setup do
    # Create an ETS table for testing purposes
    init_table(@magic_link_table)
    init_table(@session_table)
    :ok
  end

  describe "store_token/4" do
    setup do
      {_, token} = UserToken.build_token()
      email = "test@example.com"
      ttl = 10
      {:ok, %{token: token, email: email, ttl: ttl}}
    end

    test "stores magic link token correctly", %{token: token, email: email, ttl: ttl} do
      TokenStore.store_token(:magic_link, token, email, ttl)

      assert [{^token, ^email, _}] = :ets.lookup(@magic_link_table, token)
    end

    test "stores session token correctly", %{token: token, email: email, ttl: ttl} do
      TokenStore.store_token(:session, token, email, ttl)

      assert [{^token, ^email, _}] = :ets.lookup(@session_table, token)
    end
  end

  defp init_table(table) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:set, :public, :named_table, read_concurrency: true])
    end
  end
end
