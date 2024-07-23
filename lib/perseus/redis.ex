defmodule Perseus.Redis do
  def get(key) do
    key = ensure_string(key)
    Redix.command(:redix, ["GET", key])
  end

  def set(key, value) do
    key = ensure_string(key)
    Redix.command(:redix, ["SET", key, value])
  end

  def set(key, value, exp) when is_integer(exp) do
    key = ensure_string(key)
    Redix.command(:redix, ["SETEX", key, exp, value])
  end

  def del(key) do
    key = ensure_string(key)
    Redix.command(:redix, ["DEL", key])
  end

  def set_hash(key, %{} = map) do
    key = ensure_string(key)

    {:ok, [_, fields_set]} =
      Redix.pipeline(:redix, [["DEL", key], ["HSET", key | map_to_redis_args(map)]])

    {:ok, fields_set}
  end

  def set_map_attr(key, field, value) do
    key = ensure_string(key)
    field = ensure_string(field)

    Redix.command(:redix, ["HSET", key, field, value])
  end

  def get_map_attr(key, field) do
    key = ensure_string(key)
    field = ensure_string(field)

    case Redix.command(:redix, ["HGET", key, field]) do
      {:ok, values} ->
        {:ok, redis_args_to_map(values)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ensure_string(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp ensure_string(str) when is_binary(str), do: str

  defp map_to_redis_args(map) do
    Enum.flat_map(map, fn {key, value} -> [key, value] end)
  end

  defp redis_args_to_map(args) do
    args
    |> Enum.chunk_every(2)
    |> Enum.into(%{}, fn [field, value] -> {field, value} end)
  end
end
