defmodule Aggregation.Store.AdapterShared do
  defmacro __using__(for: module) do
    quote do
      use ExUnit.Case, async: true

      import Aggregation.TestHelpers
      alias unquote(module), as: Adapter

      use_per_test_streams adapter: Adapter

      defmodule MyEvent, do: defstruct [:key]

      test "it stores the events", %{stream: stream} do
        events = [%MyEvent{key: "value"}]
        Adapter.store_events(events, stream)
        eventually do
          assert Adapter.read_all(stream) == events
        end
      end

      test "it allows to subscribe to given stream", %{stream: stream} do
        Adapter.subscribe_to stream
        event = %MyEvent{key: "value"}
        Adapter.store_events([event], stream)
        eventually do
          assert_receive {:stream_event, ^stream, ^event }
        end
      end
    end
  end
end
