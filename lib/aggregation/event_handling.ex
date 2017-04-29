defmodule Aggregation.EventHandling do
  defmodule UnknownEvent do
    defexception message: "Unknown event!"
  end

  defmodule Behaviour do
    @callback apply(map, map) :: any;
  end

  defmacro __using__(unknown_event: uknown_event_mode) do
    quote do
      @unknown_event_mode unquote(uknown_event_mode)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(
      Module.get_attribute(env.module, :unknown_event_mode)
    )
  end

  defp compile(mode) do
    quote do
      unquote(define_default_handler mode)
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
end
