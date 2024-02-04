defmodule RedisMutex.Lock do
  @moduledoc """
  Defines the lock for RedisMutex.
  """

  @unlock_script """
  if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
  else
    return 0
  end
  """
  @default_timeout :timer.seconds(40)
  @default_expiry :timer.seconds(20)
  @default_name RedisMutex

  @spec with_lock(key :: String.t(), fun :: (-> any()), opts :: RedisMutex.lock_opts()) :: any()
  def with_lock(key, fun, opts \\ []) do
    name = Keyword.get(opts, :name, @default_name)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    expiry = Keyword.get(opts, :expiry, @default_expiry)
    uuid = Uniq.UUID.uuid1()
    take_lock(key, name, uuid, timeout, expiry)
    result = fun.()
    unlock(key, name, uuid)
    result
  end

  @spec take_lock(
          key :: String.t(),
          name :: RedisMutex.name(),
          uuid :: String.t(),
          timeout :: non_neg_integer(),
          expiry :: non_neg_integer(),
          finish :: DateTime.t()
        ) :: boolean()
  defp take_lock(
         key,
         name,
         uuid,
         timeout,
         expiry,
         finish \\ nil
       )

  defp take_lock(key, name, uuid, timeout, expiry, nil) do
    finish = DateTime.add(DateTime.utc_now(), timeout, :millisecond)
    take_lock(key, name, uuid, timeout, expiry, finish)
  end

  defp take_lock(key, name, uuid, timeout, expiry, finish) do
    if DateTime.compare(finish, DateTime.utc_now()) == :lt do
      raise RedisMutex.Error, message: "Unable to obtain lock."
    end

    if !lock(key, name, uuid, expiry) do
      take_lock(key, name, uuid, timeout, expiry, finish)
    end
  end

  @spec lock(
          key :: String.t(),
          name :: RedisMutex.name(),
          value :: String.t(),
          expiry :: non_neg_integer()
        ) :: boolean()
  defp lock(key, name, value, expiry) do
    case Redix.command!(name, ["SET", key, value, "NX", "PX", "#{expiry}"]) do
      "OK" -> true
      nil -> false
    end
  end

  @spec unlock(
          key :: String.t(),
          name :: RedisMutex.name(),
          value :: String.t()
        ) ::
          boolean()
  defp unlock(key, name, value) do
    case Redix.command!(name, ["EVAL", @unlock_script, 1, key, value]) do
      1 -> true
      0 -> false
    end
  end
end
