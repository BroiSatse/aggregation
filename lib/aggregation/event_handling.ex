defmodule Aggregation.EventHandling do
  defmodule UnknownEvent do
    defexception message: "Unknown event!"
  end

  defmacro __using__(unknown_event: uknown_event_mode) do
    quote do
      Module.register_attribute __MODULE__, :event_handlers, accumulate: true

      import unquote(__MODULE__), only: [handle_event: 3]
      @unknown_event_mode unquote(uknown_event_mode)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro handle_event(aggregate, event, do: block) do
    quote do
      @event_handlers {
        unquote(Macro.escape(aggregate)),
        unquote(Macro.escape(event)),
        unquote(Macro.escape(block))
      }
    end
  end

  defmacro __before_compile__(env) do
    compile(
      Module.get_attribute(env.module, :event_handlers),
      Module.get_attribute(env.module, :unknown_event_mode)
    )
  end

  defp compile(handlers, mode) do
    quote do
      unquote_splicing(
        Enum.map handlers, fn {aggregate, event, block} ->
          define_handler(aggregate, event, block)
        end
      )
      unquote(define_default_handler(mode))
   end
  end

  def define_default_handler(mode) do
    case mode do
      :raise ->
        quote do
          def apply(_, event) do
            raise unquote(__MODULE__).UnknownEvent,
              message: "Aggregate #{inspect __MODULE__} does not know how to handle event #{inspect event}"
          end
        end
      :ignore ->
        quote do
          def apply(_, _) do
          end
        end
    end
  end

  defp define_handler(aggregate, event, block) do
    quote do
      def apply(unquote(aggregate), unquote(event)), do: unquote(block)
    end
  end
end