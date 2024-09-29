defmodule Perseus.Auth.UserTokenTest do
  use Perseus.DataCase

  alias Perseus.Auth.UserToken

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
  end
end
