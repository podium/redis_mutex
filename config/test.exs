import Config

config :redis_mutex,
  lock_module: RedisMutex.LockMock,
  redis_options: [
    host: "localhost",
    port: 6379
  ]
