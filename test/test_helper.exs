ExUnit.configure(exclude: [:redis_dependent])
ExUnit.start(exclude: [:skip])

{:ok, files} = File.ls("./test/support")

Enum.each(files, fn file ->
  Code.require_file("support/#{file}", __DIR__)
end)
