use Mix.Config

config :logger, level: :debug

config :jwt, :googlecerts, Jwt.GoogleCerts.PublicKey
config :jwt, :firebasecerts, Jwt.FirebaseCerts.PublicKey