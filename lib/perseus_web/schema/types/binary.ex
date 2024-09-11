defmodule PerseusWeb.Schema.Types.Binary do
  use Absinthe.Schema.Notation

  alias Perseus.Utils.BinaryUtils

  scalar :binary do
    description("A binary data type")

    parse fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, decoded_value} <- BinaryUtils.decode(value) do
        {:ok, decoded_value}
      else
        _ -> :error
      end
    end

    serialize &BinaryUtils.encode/1
  end
end
