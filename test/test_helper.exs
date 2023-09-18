ExUnit.configure(exclude: [:redis_dependent])
ExUnit.start(exclude: [:skip])

Mox.defmock(RedisMutex.LockV2Mock, for: RedisMutex.LockV2)
