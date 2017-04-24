defmodule Aggregation.Helpers.Config do
  defmacro config(key, default \\ nil) do
    block = quote do
      Application.get_env(:aggregate, :store, [])
      |> Keyword.get(unquote(key), unquote(default))
    end

    if Mix.env == :production do
      {:ok, result} = Code.eval_quoted(block)
      quote do: unquote(result)
    else
      block
    end
  end

  defmacro store_adapter do
    module_name = config(:adapter, :event_store)
    |> to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join

    String.to_atom("#{Aggregation.Store}.#{module_name}")
  end
end
