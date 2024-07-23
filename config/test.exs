import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :perseus, Perseus.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "perseus_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :perseus, Perseus.Redis,
  host: "localhost",
  port: 6379

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :perseus, PerseusWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "1XZPlwBtdjC3g1YFALEt30oMd7dtxForpOQr+sD3IcAKx2/5a1mzav0vMMqNnNq4",
  server: false

# In test we don't send emails.
config :perseus, Perseus.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
