# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ether,
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :ether, EtherWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: EtherWeb.ErrorHTML, json: EtherWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ether.PubSub,
  live_view: [signing_salt: "AjbfszvY"]

# Configure live_svelte with Bun
config :live_svelte,
  bundle_command: "bun run build.js",
  ssr_command: "bun run ../assets/js/ssr.js",
  cd: Path.expand("../assets", __DIR__)

# Configure zigler
config :zigler, local_zig: true

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
