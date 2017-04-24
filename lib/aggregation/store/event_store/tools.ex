defmodule Aggregation.Store.EventStore.Tools do
  alias Extreme.Messages, as: Msg

  def decode_event(%Msg.EventRecord{event_type: event_type, data: data}) do
    event_type = String.to_existing_atom(event_type)
    Poison.decode!(data, as: struct(event_type))
  end
end
