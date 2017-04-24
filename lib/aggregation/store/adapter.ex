defmodule Aggregation.Store.Adapter do
    @callback store_events(events :: list(map), stream :: String.t) :: {:ok, list(map)} | {:error, String.t}
    @callback read_all(stream_name :: String.t) :: list(map)
    @callback subscribe_to(stream_name :: String.t) :: {:ok | :error, String.t}
    @callback subscribe_to(stream_name :: String.t, opts :: keyword) :: {:ok | :error, String.t}
    @callback delete_stream!(stream :: String.t) :: {:ok | :error, String.t}
end
