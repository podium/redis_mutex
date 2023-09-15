ExUnit.configure(exclude: [:redis_dependent])
ExUnit.start(exclude: [:skip])

{:ok, files} = File.ls("./test/support")
Mox.defmock(RedisMutex.LockV2Mock, for: RedisMutex.LockV2)

Enum.each(files, fn file ->
  Code.require_file("support/#{file}", __DIR__)
end)
