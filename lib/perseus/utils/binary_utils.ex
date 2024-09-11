defmodule Perseus.Utils.BinaryUtils do

  @doc """
  Encodes binary data using Base64 URL encoding without padding.
  """
  def encode(token) do
    Base.url_encode64(token, padding: false)
  end

  @doc """
  Decodes Base64 URL-encoded data, allowing for data without padding.
  """
  def decode(token) do
    Base.url_decode64(token, padding: false)
  end
end
