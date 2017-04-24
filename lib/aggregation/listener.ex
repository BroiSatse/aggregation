defmodule Aggregation.Listener do
  use GenServer

  defmacro __using__([stream: stream] = opts) do
    quote do
      @before_compile unquote(__MODULE__)

      def start_link do
        GenServer.start_link __MODULE__, :ok
      end

      def init(:ok) do
        {:ok, _} = Aggregation.Store.subscribe_to(unquote(stream))
        state = if Module.defines?(__MODULE__, :init_with) do
          __MODULE__.init_with
        else
          nil
        end
        {:ok, }
      end

      def handle_info({:stream_event, stream, decoded}) do
        handle_event(stream, decoded)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(_, _) do
      end
    end
  end

  def start_link(module) do
    GenServer.start_link __MODULE__, module
  end

  def init(module) do

  end
end