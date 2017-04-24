defmodule Aggregation.Store do
  @behaviour Aggregation.Store.Adapter

  import Aggregation.Helpers.Config
  @store store_adapter()

  @doc """
  Stores given events within EventStore database
  """
  def store_events(events, stream) do
    @store.store_events(events, stream)
  end

  @doc """
  Returns all the events on given stream. Does not subscribe.
  """
  def read_all(stream_name) do
    @store.read_all(stream_name)
  end

  @doc """
  Subscribes current process to given stream
  """
  def subscribe_to(stream_name, opts \\ []) do
    @store.subscribe_to(stream_name, opts)
  end

  @doc """
  Deletes given stream
  """
  def delete_stream!(stream_name) do
    @store.delete_stream!(stream_name)
  end
end

defmodule Aggregation.Store.Supervisor do
  import Aggregation.Helpers.Config
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(store_adapter().Supervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
