defmodule Aggregation do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Aggregation.Register, []),
      supervisor(Aggregation.Supervisor, []),
      supervisor(Aggregation.Store.Supervisor, [])
    ]

    Supervisor.start_link children, strategy: :one_for_one
  end
end
