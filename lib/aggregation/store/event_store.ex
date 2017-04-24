defmodule Aggregation.Store.EventStore do
  alias Extreme.Messages, as: Msg
  alias Aggregation.Store.EventStore.SubscriptionSupervisor

  alias __MODULE__.Tools

  @behaviour Aggregation.Store.Adapter
  @store_name __MODULE__

  def store_events(events, stream) do
    query = events
    |> extremize_events()
    |> build_write_query(stream)

    Extreme.execute(@store_name, query)
  end

  def read_all(stream_name) do
    query = Msg.ReadStreamEvents.new(
      event_stream_id: stream_name,
      from_event_number: 0,
      max_count: 4096,
      resolve_link_tos: true,
      require_master: false
    )
    case Extreme.execute(@store_name, query) do
      {:ok, response} ->
        Enum.map response.events, &(Tools.decode_event(&1.event))
      {:error, :NoStream, _} -> []
    end
  end

  def delete_stream!(stream_name) do
    query = Msg.DeleteStream.new(
      event_stream_id: stream_name,
      expected_version: -2,
      require_master: false,
      hard_delete: false
    )
    Extreme.execute @store_name, query
  end

  def subscribe_to(stream, opts \\ []) do
    SubscriptionSupervisor.start_subscriber(stream, self(), opts)
  end

  defp extremize_events(events) do
    Enum.map(events, fn event ->
      Msg.NewEvent.new(
       event_id: Extreme.Tools.gen_uuid(),
       event_type: to_string(event.__struct__),
       data_content_type: 0,
       metadata_content_type: 0,
       data: Poison.encode!(event),
       metadata: ""
      )
    end)
  end

  defp build_write_query(events, stream_id) do
    Msg.WriteEvents.new(
      event_stream_id: stream_id,
      expected_version: -2,
      events: events,
      require_master: false
    )
  end
end
