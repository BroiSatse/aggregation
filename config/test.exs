use Mix.Config

config :aggregate, :store,
  stream_prefix: :test

config :logger,
  level: :warn
