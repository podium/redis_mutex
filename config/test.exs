import Config

config :redis_mutex, redis_url: "redis://localhost:6379"

config :redis_mutex, RedisMutexV2Test.RedisMutexUser,
  lock_module: RedisMutex.LockV2Mock,
  redis_url: "redis://localhost:6379"
