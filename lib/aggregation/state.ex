defmodule Aggregation.State do

  @stream_prefix Application.get_env(:aggregate, :store, []) |> Keyword.get(:stream_prefix)

  defmacro __using__(opts) do
    name = opts[:stream] || raise "Aggregate.State requires stream: option"
    timeout = opts[:timout] || 5000
    quote do
      use Aggregation.EventHandling, unknown_event: :raise
      def stream do
        unquote(
          [@stream_prefix, name]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(":")
        )
      end

      def __timeout, do: unquote(timeout)
    end
  end

  def apply(aggregate, events) when is_list(events) do
    Enum.reduce events, aggregate, &(__MODULE__.apply &2, &1)
  end

  def apply(aggregate, event) do
    aggregate.__struct__.apply(aggregate, event)
  end

  def command(aggregate, %{__struct__: command_type} = command) do
    command_type.apply(aggregate, command)
  end
end
