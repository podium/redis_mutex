ExUnit.start()
ExUnit.configure(exclude: [:redis_dependent, :skip])

# Mox.defmock(RedisMutex.LockMock, for: RedisMutex.Lock)
