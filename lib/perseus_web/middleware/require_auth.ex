defmodule PerseusWeb.Middleware.RequireAuth do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    case resolution.context[:current_user] do
      nil ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Unauthorized"})

      _user ->
        resolution
    end
  end
end
