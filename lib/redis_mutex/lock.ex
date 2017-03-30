defmodule RedisMutex.Lock do
  import Exredis.Script

  @moduledoc """
  This module contains the actual Redis locking business logic. The `with_lock`
  macro is generally the only function that should be used from this module, as it
  will handle the logic for setting and removing key/values in Redis.
  """

  defredis_script :unlock_script, """
  if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
  else
    return 0
  end
  """

  @default_timeout :timer.seconds(40)
  @expiry :timer.seconds(20)


  @doc """
    This macro takes in a key and a timeout.

    A key might be be an id or a resource identifier that will
    lock a particular resource. A good example might be an email or phone
    number for a user, and you might want lock a db insert so that
    multiple users aren't created for one email or phone number.

    The timeout is in milliseconds and defaults to 40000 milliseconds.
    There is a key expiration of 20 seconds, so the timeout should always
    be greater than 20 seconds. The 20 second expiry allows the key to expire
    in case the logic inside the `with_lock` macro throws an error or fails
    to complete within 20 seconds, thereby freeing up the key so the lock
    can be obtained by another request or resource.

    The lock will be released after the logic inside the `with_lock` has
    completed, or the timeout, whatever comes first. The return value
    of the macro will be whatever the return value of what's inside
    the 'with_lock' macro.

    defmodule PossumLodge do
      use RedisMutex
      alias PossumLodge.{Repo, Member}

      def add_member(params) do
        with_lock(params.phone_number) do
          %Member{}
          |> Member.changeset(params)
          |> Repo.insert_or_update!
        end
      end
    end
  """

  defmacro with_lock(key, timeout \\ @default_timeout, do: clause) do
    quote do
      key = unquote(key)
      timeout = unquote(timeout)
      uuid = UUID.uuid1()

      RedisMutex.Lock.take_lock(key, uuid, timeout)

      block_value = unquote(clause)

      RedisMutex.Lock.unlock(key, uuid)

      block_value
    end
  end

  @doc """
  This function can be called manually. It takes in a key, unique string, and a timeout
  in milliseconds. It will call itself recursively until it is able to set a lock
  or the timeout expires.
  """
  def take_lock(key, uuid, timeout \\ @default_timeout, start \\ nil, finish \\ nil)
  def take_lock(key, uuid, timeout, nil, nil) do
    start = Timex.now
    finish = Timex.shift(start, milliseconds: timeout)
    take_lock(key, uuid, timeout, start, finish)
  end
  def take_lock(key, uuid, timeout, start, finish) do
    if Timex.before?(finish, start) do
      raise RedisMutex.Error, message: "Unable to obtain lock."
    end

    if !lock(key, uuid) do
      take_lock(key, uuid, timeout, start, finish)
    end
  end

  @doc """
  This function takes in a key and a unique identifier to set it in Redis.
  This is how a lock is identified in Redis. If a key/value pair is able to be
  set in Redis, `lock` returns `true`. If it isn't able to set in Redis, `lock`
  returns `false`.
  """
  def lock(key, value) do
    client = Process.whereis(:redis_mutex_connection)

    case Exredis.query(client, ["SET", key, value, "NX", "PX", "#{@expiry}"]) do
      "OK" -> true
      :undefined -> false
    end
  end


  @doc """
  This function takes in the key and value that are to be released in Redis
  """
  def unlock(key, value) do
    client = Process.whereis(:redis_mutex_connection)

    case unlock_script(client, [key], [value]) do
      "1" -> true
      "0" -> false
    end
  end
end
