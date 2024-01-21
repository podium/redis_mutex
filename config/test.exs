import Config

config :redis_mutex,
  lock_module: RedisMutex.LockMock,
  redis_options: [
    name: RedisMutex,
    host: "localhost",
    port: 6379
  ]
