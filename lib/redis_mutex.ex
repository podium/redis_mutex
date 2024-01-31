defmodule RedisMutex do
  @moduledoc """
  An Elixir library for using Redis locks.
  """
  @type connection_options :: [
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

  @type start_options :: {:redis_url, String.t()} | connection_options()
  @type name :: String.t() | atom() | module()

  @default_name RedisMutex

  @callback child_spec(opts :: Keyword.t()) :: Supervisor.child_spec()

  @callback start_link(start_options :: RedisMutex.start_options()) ::
              {:ok, pid()} | {:error, any()}

  @callback with_lock(key :: String.t(), fun :: (-> any())) :: any()

  @callback with_lock(key :: String.t(), opts :: lock_opts(), fun :: (-> any())) :: any()

  @spec child_spec(opts :: Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @spec start_link(start_options()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(start_options \\ []) do
    {redis_url, redis_options} = set_options(start_options)
    connect_to_redis(redis_url, redis_options)
  end

  @spec with_lock(key :: String.t(), opts :: lock_opts(), fun :: (-> any())) :: any()
  def with_lock(key, opts \\ [], fun) do
    RedisMutex.Lock.with_lock(key, opts, fun)
  end

  defp set_options(start_options) do
    name = Keyword.get(start_options, :name, @default_name)
    config_opts = Application.get_env(:redis_mutex, name)

    merged_opts =
      config_opts
      |> Keyword.merge(start_options)
      |> Keyword.merge(name: name, sync_connect: true)

    {redis_url, other_opts} = Keyword.pop(merged_opts, :redis_url)

    redis_options =
      cond do
        is_binary(redis_url) ->
          Keyword.take(other_opts, [:name, :sync_connect])

        true ->
          other_opts
      end

    {redis_url, redis_options}
  end

  defp connect_to_redis(redis_url, redis_options) when is_binary(redis_url) do
    Redix.start_link(redis_url, redis_options)
  end

  defp connect_to_redis(_redis_url, redis_options) do
    Redix.start_link(redis_options)
  end
end
