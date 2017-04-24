defmodule Aggregation.Store.EventStore.SubscriptionSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_subscriber(stream, process, opts \\ []) do
    Supervisor.start_child(__MODULE__, [stream, process, opts])
  end

  def init(:ok) do
    children = [
      worker(Aggregation.Store.EventStore.Subscriber, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
