defmodule RedisMutex.Lock do
  import Exredis.Script

  defredis_script :unlock_script, """
  if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
  else
    return 0
  end
  """

  @default_timeout :timer.seconds(30)
  @expiry :timer.seconds(10)

  defmacro with_lock(key, timeout \\ @default_timeout, do: clause) do
    quote do
      key = unquote(key)
      uuid = UUID.uuid1()

      RedisMutex.Lock.take_lock(key, uuid, timeout)

      block_value = unquote(clause)

      RedisMutex.Lock.unlock(key, uuid)

      block_value
    end
  end

  def take_lock(key, uuid, timeout \\ @default_timeout, start \\ nil, finish \\ nil)
  def take_lock(key, uuid, timeout, nil, nil) do
    start = Timex.now
    finish = Timex.shift(start, milliseconds: unquote(timeout))
    take_lock(key, uuid, timeout, start, finish)
  end
  def take_lock(key, uuid, timeout, start, finish) do
    if Timex.before?(finish, start) do
      raise RedisMutex.Error, message: "Unable to obtain lock."
    end

    if !lock(key, uuid) do
      take_lock(key, uuid, start, finish)
    end
  end

  def lock(key, value) do
    client = Process.whereis(:redis_mutex_connection)

    case Exredis.query(client, ["SET", key, value, "NX", "PX", "#{@expiry}"]) do
      "OK" -> true
      :undefined -> false
    end
  end

  def unlock(key, value) do
    client = Process.whereis(:redis_mutex_connection)

    case unlock_script(client, [key], [value]) do
      "1" -> true
      "0" -> false
    end
  end
end
