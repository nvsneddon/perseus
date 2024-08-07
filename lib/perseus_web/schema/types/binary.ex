defmodule PerseusWeb.Schema.Types.Binary do
  use Absinthe.Schema.Notation

  scalar :binary do
    description("A binary data type")

    parse fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case Base.url_decode64(value) do
          {:ok, decoded_value} -> {:ok, decoded_value}
          _ -> :error
        end

      _ ->
        :error
    end

    serialize &Base.url_encode64/1
  end
end
