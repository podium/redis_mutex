defmodule RedisMutex do
  @moduledoc """
  An Elixir library for using Redis locks.
  """

  @type name :: String.t() | atom() | module()

  @typedoc """
  Options for connecting to Redis.

   ## Options

    * `:name` - the name to use for a Redis connection. When not provided, the connection name
      defaults to `RedisMutex`. If you have provided a different name for the connection
      during initiation of the connection, you must provide that name in the options for
      `with_lock/3`.

    * `:redis_url` - The URL to use connecting to Redis. When this is provided, other options are
      not needed. When `:redis_url` is provided, the only other options honored are `:name`
      and `:sync_connect`.

    When `:redis_url` is not provided, other connection options (like `:host` and `:port`) must be
    provided.
  """
  @type connection_options :: [
          name: name(),
          redis_url: String.t(),
          host: String.t(),
          port: non_neg_integer(),
          database: String.t() | non_neg_integer(),
          username: String.t(),
          password: Redix.password(),
          timeout: timeout(),
          sync_connect: boolean(),
          exit_on_disconnection: boolean(),
          backoff_initial: non_neg_integer(),
          backoff_max: timeout(),
          ssl: boolean(),
          socket_opts: list(term()),
          hibernate_after: non_neg_integer(),
          spawn_opt: keyword(),
          debug: keyword(),
          sentinel: keyword()
        ]

  @type lock_opts :: [
          name: name(),
          timeout: non_neg_integer(),
          expiry: non_neg_integer()
        ]

  @default_name RedisMutex

  @callback child_spec(opts :: connection_options()) :: Supervisor.child_spec()

  @callback start_link(start_options :: connection_options()) ::
              {:ok, pid()} | {:error, any()}

  @callback with_lock(key :: String.t(), fun :: (-> any())) :: any()

  @callback with_lock(key :: String.t(), fun :: (-> any()), opts :: lock_opts()) :: any()

  @doc """
  The specification for starting a connection with Redis. Can include any of the
  `connection_options`.
  """
  @spec child_spec(opts :: connection_options()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Starts a process as part of a supervision tree.
  """
  @spec start_link(connection_options()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(start_options) do
    {redis_url, redis_options} = set_options(start_options)
    connect_to_redis(redis_url, redis_options)
  end

  @doc """
  Provides a mutex for performing a function.

  The lock is defined by the key argument. When the key is already taken, the function will not be
  performed. When the key is not already in use, the function argument is run.

  The key should be unique to the operation being performed.

  The function provided should be a zero-arity function.

   ## Options

    * `:name` - the name of the Redis connection to use when performing the lock.
      Defaults to `RedisMutex`. If you have provided a different name for the connection
      during initiation of the connection, you must provide that name in the options for
      `with_lock/3`.

    * `:timeout` - how long `RedisMutex` will try before abandoning the attempt to gain the
    lock. Timeout is in milliseconds. Defaults to 4_000.

    * `:expiry` - how long the lock will be held before expiring. Expiry is in milliseconds.
    Defaults to 2_000.
  """
  @spec with_lock(key :: String.t(), fun :: (-> any()), opts :: lock_opts()) :: any()
  def with_lock(key, fun, opts \\ []) do
    RedisMutex.Lock.with_lock(key, fun, opts)
  end

  defp set_options(start_options) do
    redis_url = Keyword.get(start_options, :redis_url)
    name = Keyword.get(start_options, :name, @default_name)
    sync_connect = Keyword.get(start_options, :sync_connect, true)
    base_options = [name: name, sync_connect: sync_connect]

    redis_options =
      if is_binary(redis_url) do
        base_options
      else
        start_options
        |> Keyword.drop([:redis_url])
        |> Keyword.merge(base_options)
      end

    {redis_url, redis_options}
  end

  @spec connect_to_redis(redis_url :: String.t() | nil, Keyword.t()) ::
          {:ok, pid()} | :ignore | {:error, term()}
  defp connect_to_redis(redis_url, redis_options) when is_binary(redis_url) do
    Redix.start_link(redis_url, redis_options)
  end

  defp connect_to_redis(_redis_url, redis_options) do
    Redix.start_link(redis_options)
  end
end
