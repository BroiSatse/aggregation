defmodule Aggregation.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_aggregate(type, uuid) do
    Supervisor.start_child(__MODULE__, [type, uuid])
  end

  def init(:ok) do
    children = [
      worker(Aggregation.Aggregate, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
