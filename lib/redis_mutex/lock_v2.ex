defmodule RedisMutex.LockV2 do
  @moduledoc """
  Defines the lock behaviour for RedisMutex.
  """

  @callback start_link(start_options :: Keyword.t()) :: {:ok, pid()} | {:error, any()}

  @callback with_lock(key :: String.t(), timeout :: integer(), expiry :: integer(), do: clause :: term()) ::
              any()
end
