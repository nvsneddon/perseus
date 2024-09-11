defmodule Perseus.Accounts.UserToken do
  @hash_algorithm :sha256
  @rand_size 32

  def build_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {token, hashed_token}
  end

  def verify_hash(token, expected_hash) do
    {:ok, :crypto.hash(@hash_algorithm, token) == expected_hash}
  end

  def hash(token) do
    :crypto.hash(@hash_algorithm, token)
  end
end
