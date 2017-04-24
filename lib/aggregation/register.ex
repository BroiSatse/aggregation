defmodule Aggregation.Register do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get(type, uuid) do
    GenServer.call(__MODULE__, {:get, type, uuid})
  end

  def init(:ok) do
    {:ok, {%{}, %{}}}
  end

  def handle_call({:get, type, uuid}, _, {registry, _} = state) do
    case Map.fetch(registry, {type, uuid}) do
      {:ok, aggregate} ->
        if Process.alive?(aggregate) do
          Aggregation.Aggregate.poke aggregate
          {:reply, aggregate, state}
        else
          new_aggregate(type, uuid, state)
        end
      :error ->
        new_aggregate(type, uuid, state)
    end
  end

  def handle_info({:DOWN, reference, :process, _, _}, {registry, refs}) do
    {key, new_refs} = Map.pop(refs, reference)
    new_registry = Map.delete(registry, key)
    {:noreply, {new_registry, new_refs}}
  end

  defp new_aggregate(type, uuid, {registry, refs}) do
    {:ok, pid} = Aggregation.Supervisor.start_aggregate(type, uuid)
    key = {type, uuid}
    new_registry = Map.put(registry, key, pid)
    new_refs = Map.put(refs, Process.monitor(pid), key)
    {:reply, pid, {new_registry, new_refs}}
  end
end
