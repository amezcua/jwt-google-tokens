use Mix.Config

config :logger, level: :debug

config :jwt, :googlecerts, Jwt.GoogleCerts.PublicKey.Mock
config :jwt, :firebasecerts, Jwt.FirebaseCerts.PublicKey.Mock
config :jwt, :timeutils, Jwt.TimeUtils.Mock