defmodule Aggregation.Aggregate do

  alias Aggregation.{Store, State, Register}

  def start_link(aggregate_type, uuid) do
    mname = Module.split(aggregate_type) |> List.last
    GenServer.start_link(__MODULE__.Server, {aggregate_type, uuid}, name: String.to_atom("#{mname}:#{uuid}"))
  end

  def new(aggregate_type) do
    uuid = UUID.uuid1
    {uuid, get(aggregate_type, uuid)}
  end

  def get(aggregate_type, uuid) do
    Register.get(aggregate_type, uuid)
  end

  def command(pid, command) do
    GenServer.call(pid, {:command, command})
  end

  def command!(pid, command) do
    GenServer.call(pid, {:command!, command})
  end

  def stream(pid) do
    GenServer.call(pid, :stream)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def poke(pid) do
    GenServer.cast(pid, :poke)
  end

  defmodule Server do
    use GenServer

    def init({aggregate_type, uuid}) do
      state = struct(aggregate_type)
      state = State.apply(state, Store.read_all(stream(uuid, state)))
      {:ok, {uuid, state}, aggregate_type.__timeout}
    end

    def handle_call({:command, command}, _from, {uuid, state}) do
      {:reply, try_command(state, command), {uuid, state}, state.__struct__.__timeout}
    end

    def handle_call({:command!, command}, _from, {uuid, state}) do
      result = try_command(state, command)
      case result do
        {:ok, events} ->
          {:ok, _ } = Store.store_events(events, stream(uuid, state))
          new_state = State.apply(state, events)
          {:reply, result, {uuid, new_state}, state.__struct__.__timeout}
        _ ->
          {:reply, result, {uuid, state}, state.__struct__.__timeout}
      end
    end

    def handle_call(:stream, _from, {uuid, state}) do
      {:reply, stream(uuid, state), {uuid, state}, state.__struct__.__timeout}
    end

    def handle_call(:state, _from, {uuid, state}) do
      {:reply, state, {uuid, state}, state.__struct__.__timeout}
    end

    def handle_cast(:poke, {uuid, state}) do
      {:noreply, {uuid, state}, state.__struct__.__timeout}
    end

    def handle_info(:timeout, _) do
      {:stop, :normal, []}
    end

    defp try_command(state, command) do
      command.__struct__.apply(state, command)
    end

    defp stream(uuid, state) do
      "#{state.__struct__.stream}:#{uuid}"
    end
  end
end
