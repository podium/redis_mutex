import Config

config :redis_mutex, RedisMutex, redis_url: "redis://localhost:6379"

config :redis_mutex, MyApp.RedisMutex,
  host: "localhost",
  port: 6379
