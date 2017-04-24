defmodule Aggregation.Command.Pipes do
  def validate({_, command} = state) do
    case Vex.errors(command) do
      [] -> {:ok, state}
      errors -> {:error, {:validation_failed, errors}}
    end
  end
end