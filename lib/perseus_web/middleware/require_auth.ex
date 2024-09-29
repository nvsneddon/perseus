defmodule PerseusWeb.Middleware.RequireAuth do
  @behaviour Absinthe.Middleware

  def call(%{context: %{token_type: :session, user: _}} = resolution, %{token_type: :session}) do
    resolution
  end

  def call(%{context: %{token_type: token_type, email: _}} = resolution, %{token_type: token_type})
      when token_type in [:magic_link, :signup] do
    resolution
  end

  def call(resolution, _) do
    resolution
    |> Absinthe.Resolution.put_result(
      {:error, %{message: "Unauthenticated", code: "UNAUTHENTICATED"}}
    )
  end
end
