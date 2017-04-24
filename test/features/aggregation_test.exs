defmodule AggregationTest do
  require IEx
  use ExUnit.Case, async: true

  import Aggregation.TestHelpers
  alias Aggregation.Aggregate

  defmodule SimpleAggregate do
    use Aggregation.State, stream: "simple"
    defstruct counter: 0, event_counter: 0

    defmodule Added, do: defstruct [:number]
    defmodule Add do
      use Aggregation.Command

      defstruct [:number]

      validates :number, presence: true

      pipe Pipes, :validate
      pipe :ensure_small
      pipe :publish_event

      def ensure_small({%{counter: counter}, %{number: number}} = state) do
        if counter + number > 10 do
          {:error, "Counter cannot be greater than 10"}
        else
          {:ok, state}
        end
      end

      def publish_event({_, %{number: number}}) do
        {:ok, [%Added{number: number}]}
      end
    end

    handle_event(aggregate, %Added{number: number}) do
      %__MODULE__{counter: aggregate.counter + number, event_counter: aggregate.event_counter + 1}
    end
  end

  test "Simple lifetime of the aggregate" do
    {uuid, aggregate} = Aggregate.new(SimpleAggregate)
    stream = Aggregate.stream aggregate
    with_stream(stream) do
      assert Aggregate.state(aggregate) == %SimpleAggregate{counter: 0, event_counter: 0}

      {:error, result} = Aggregate.command!(aggregate, %SimpleAggregate.Add{})
      assert result == {:validation_failed, [{:error, :number, :presence, "must be present"}]}

      {:ok, _} = Aggregate.command!(aggregate, %SimpleAggregate.Add{number: 5})
      assert Aggregate.state(aggregate) == %SimpleAggregate{counter: 5, event_counter: 1}

      assert Aggregate.command!(aggregate, %SimpleAggregate.Add{number: 6}) == {:error, "Counter cannot be greater than 10"}

      {:ok, _} = Aggregate.command!(aggregate, %SimpleAggregate.Add{number: 3})
      assert Aggregate.state(aggregate) == %SimpleAggregate{counter: 8, event_counter: 2}

      send(aggregate, :timeout)
      eventually do: refute Process.alive?(aggregate)

      aggregate = Aggregate.get(SimpleAggregate, uuid)
      assert Aggregate.state(aggregate) == %SimpleAggregate{counter: 8, event_counter: 2}
    end
  end
end
