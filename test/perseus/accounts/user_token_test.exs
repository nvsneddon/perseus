defmodule Perseus.Accounts.UserTokenTest do
  use Perseus.DataCase

  alias Perseus.Accounts.UserToken

  describe "build_token/0" do
    test "builds token that can be verified" do
      {token, hash} = UserToken.build_token()
      assert UserToken.verify_hash(token, hash)
    end
  end

  describe "verify_hash/2" do
    test "verifies correct token" do
      {token, hash} = UserToken.build_token()
      {token2, hash2} = UserToken.build_token()

      assert {:ok, true} = UserToken.verify_hash(token, hash)
      assert {:ok, false} = UserToken.verify_hash(token2, token)
      assert {:ok, false} = UserToken.verify_hash(token, hash2)
      assert {:ok, true} = UserToken.verify_hash(token2, hash2)
    end

    test "returns error when nontoken is passed to the token" do
      {_, hash} = UserToken.build_token()
      assert :error = UserToken.verify_hash("not 64 string", hash)
    end

    test "returns error when nontoken is passed to the hash" do
      {token, _} = UserToken.build_token()
      assert :error = UserToken.verify_hash(token, "non 64 string")
    end
  end
end
