defmodule PerseusWeb.Middleware.RequireAuth do
  @behaviour Absinthe.Middleware

  def call(%{context: %{token_type: :session, user: _}} = resolution, :session) do
    resolution
  end

  def call(%{context: %{token_type: token_type, email: _}} = resolution, token_type)
      when token_type in [:magic_link, :signup] do
    resolution
  end

  def call(%{context: %{error: message}} = resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, %{message: message, code: "UNAUTHENTICATED"}})
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result(
      {:error, %{message: "Unauthenticated", code: "UNAUTHENTICATED"}}
    )
  end
end
