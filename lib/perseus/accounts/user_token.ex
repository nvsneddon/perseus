defmodule Perseus.Accounts.UserToken do
  @hash_algorithm :sha256
  @rand_size 32

  def build_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {encode(token), encode(hashed_token)}
  end

  def verify_hash(token, expected_hash) do
    with {:ok, decoded_token} <- decode(token),
         {:ok, expected_decoded_hash} <- decode(expected_hash) do
      {:ok, :crypto.hash(@hash_algorithm, decoded_token) == expected_decoded_hash}
    else
      _ -> :error
    end
  end

  def get_encoded_hash(token) do
    case decode(token) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        {:ok, encode(hashed_token)}

      _ ->
        :error
    end
  end

  defp encode(token) do
    Base.url_encode64(token, padding: false)
  end

  defp decode(token) do
    Base.url_decode64(token, padding: false)
  end
end
