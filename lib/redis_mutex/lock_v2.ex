defmodule RedisMutex.LockV2 do
  @moduledoc """
  Defines the lock behaviour for RedisMutex.
  """

  @type start_options :: Keyword.t()

  @callback child_spec(start_options :: start_options()) :: Supervisor.child_spec()

  @callback start_link(start_options :: start_options()) :: {:ok, pid()} | {:error, any()}

  @callback with_lock(key :: String.t(), timeout :: integer(), expiry :: integer(),
              do: clause :: term()
            ) ::
              any()
end
