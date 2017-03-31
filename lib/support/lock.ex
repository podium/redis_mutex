defmodule RedisMutex.LockMock do

  @default_timeout :timer.seconds(40)
  @expiry :timer.seconds(20)

  @spec with_lock(any, integer) :: any
  defmacro with_lock(key, timeout \\ @default_timeout, do: clause) do
    quote do
      key = unquote(key)
      timeout = unquote(timeout)
      block_value = unquote(clause)

      block_value
    end
  end
end
