use Mix.Config

config :jelly_shot, JellyShot.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")
