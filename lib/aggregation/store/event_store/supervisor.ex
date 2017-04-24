defmodule Aggregation.Store.EventStore.Supervisor do
  use Supervisor

  def start_link do
    Application.ensure_all_started(:extreme)
    Supervisor.start_link __MODULE__, Application.get_env(:aggregate, :event_store), name: __MODULE__
  end

  def init(event_store_config) do

    children = [
      worker(Extreme, [event_store_config, [name: Aggregation.Store.EventStore]]),
      supervisor(Aggregation.Store.EventStore.SubscriptionSupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
