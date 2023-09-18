ExUnit.configure(exclude: [:redis_dependent])
ExUnit.start(exclude: [:skip])

Mox.defmock(RedisMutex.LockMock, for: RedisMutex.Lock)
