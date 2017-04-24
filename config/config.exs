use Mix.Config

config :aggregate, :event_store,
  db_type: :node,
  host: "0.0.0.0",
  port: 1113,
  username: "admin",
  password: "changeit",
  reconnect_delay: 2_000,
  max_attempts: :infinity

import_config "#{Mix.env}.exs"
