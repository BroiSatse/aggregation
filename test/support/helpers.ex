defmodule Aggregation.TestHelpers do

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  def to_stream_name(stringish) do
    stringish |> to_string |> String.replace(~r/[^\w]/, "")
  end

  defmacro eventually(timeout: timeout, do: block) do
    quote do
      fnc = fn ->
        unquote(block)
      end

      timer = Process.send_after(self(), :timeout, unquote(timeout))
      Aggregation.TestHelpers.execute_eventually(fnc, timer)
    end
  end

  defmacro eventually(do: block) do
    quote do
      unquote(__MODULE__).eventually(timeout: 200, do: unquote(block))
    end
  end

  def execute_eventually(fnc, timer) do
    try do
      fnc.()
    rescue
      e in ExUnit.AssertionError ->
        Process.sleep(20)
        receive do
          :timeout -> raise e
        after
          0 -> execute_eventually(fnc, timer)
        end
    else
      _ -> Process.cancel_timer(timer)
    end
  end

  defmacro use_per_test_streams(adapter: module) do
    quote do
      alias unquote(module), as: Store
      setup %{test: test} do
        stream_name = to_stream_name("#{__MODULE__}#{test}")
        on_exit fn ->
          Store.delete_stream!(stream_name)
        end
        [stream: stream_name]
      end
    end
  end

  defmacro use_per_test_stream do
    quote do
      unquote(__MODULE__).use_per_test_stream(adapter: Aggregation.Store)
    end
  end

  defmacro with_stream(stream_name, do: block) do
    quote do
      try do
        unquote(block)
      after
        Aggregation.Store.delete_stream!(unquote(stream_name))
      end
    end
  end
end
