import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :remote, Remote.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "remote_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :remote, RemoteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "9eGhQG5tbUrR1Sh6lKUdPIvMNCcn8vhHQchIgST68HEjb6juVnifcWruFUiQ4Y5M",
  server: false

# config for worker GenServer
config :remote, Remote.Servers.Worker, run_every: :timer.seconds(2)

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
