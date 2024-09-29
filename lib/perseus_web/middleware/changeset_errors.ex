defmodule PerseusWeb.Middleware.ChangesetErrors do
  alias Ecto.Changeset

  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    case resolution.errors do
      [%Changeset{} = changeset] when not changeset.valid? ->
        errors = transform_errors(changeset)

        resolution
        |> Absinthe.Resolution.put_result({:error, errors})

      _ ->
        resolution
    end
  end

  defp transform_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, messages} ->
      %{
        field: field,
        message: messages
      }
    end)
  end
end
