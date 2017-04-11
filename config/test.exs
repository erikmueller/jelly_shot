use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jelly_shot, JellyShot.Endpoint,
  http: [port: 4001],
  server: false

config :jelly_shot, repositories: [
  [module: JellyShot.PostRepository, source: "test/support"]
]

# Print only warnings and errors during test
config :logger, level: :warn
