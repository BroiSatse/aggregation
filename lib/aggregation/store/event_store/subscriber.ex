defmodule Aggregation.Store.EventStore.Subscriber do
  use GenServer
  alias Extreme.Messages, as: Msg
  alias Aggregation.Store.EventStore.Tools

  def start_link(stream, subscriber, from_event: from_event) do
    GenServer.start_link(__MODULE__, {stream, subscriber, from_event})
  end

  def start_link(stream, subscriber, _) do
    GenServer.start_link(__MODULE__, {stream, subscriber, nil})
  end

  def init({stream, subscriber, from_event}) do
    result = if from_event do
      Extreme.read_and_stay_subscribed(
        Aggregation.Store.EventStore,
        self(),
        stream,
        from_event
      )
    else
      Extreme.subscribe_to(
        Aggregation.Store.EventStore,
        self(),
        stream
      )
    end
    case result do
      {:ok, subscription} ->
        {:ok, {subscriber, stream, subscription}}
      _ ->
        {:error, "Could not subscribe to #{stream}"}
    end
  end

  def handle_info({:on_event, event}, {subscriber, stream, _} = state) do
    case event do
      %Msg.ResolvedEvent{event: event} ->
        decoded = event |> Tools.decode_event()
        send subscriber, {:stream_event, stream, decoded}
      sth_else -> IO.puts(sth_else)
    end
    {:noreply, state}
  end
end
