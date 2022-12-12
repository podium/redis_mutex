defmodule RedisMutex.LockMock do
  @moduledoc """
  A lock mocking helper for testing
  """
  @default_timeout :timer.seconds(40)
  @default_expiry :timer.seconds(20)

  @spec with_lock(any, integer) :: any
  defmacro with_lock(key, timeout \\ @default_timeout, expiry \\ @default_expiry, do: clause) do
    quote do
      key = unquote(key)
      timeout = unquote(timeout)
      expiry = unquote(expiry)
      block_value = unquote(clause)

      block_value
    end
  end
end
