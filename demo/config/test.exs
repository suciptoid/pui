import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :app, AppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  url: [host: "127.0.0.1"],
  check_origin: false,
  secret_key_base: "Go+ZRTW/Ne4h6HT3cw6bPZbVLOsyM/WcD6xHNTNvvigWWN7nYYIn1xgiv+dYdVl5",
  server: true

# In test we don't send emails
config :app, App.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :wallaby,
  driver: Wallaby.Chrome,
  otp_app: :app,
  chromedriver: [
    path: System.get_env("CHROMEDRIVER_PATH", "chromedriver"),
    binary:
      System.get_env(
        "GOOGLE_CHROME_BINARY",
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      )
  ]
