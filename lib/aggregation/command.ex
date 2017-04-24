defmodule Aggregation.Command do
  defmacro __using__(_opts) do
    quote do
      use Pipeline
      use Vex.Struct

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    if !Module.defines?(env.module, :apply, 2) do
      quote do
        def apply(aggregate, command) do
          unquote(__MODULE__).apply(aggregate, command)
        end
      end
    end
  end

  def apply(aggregate, command) do
    command.__struct__.pipe_through({aggregate, command})
  end
end