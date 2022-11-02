defmodule RedisMutex.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = Redix.Telemetry.attach_default_handler()

    env = Application.get_env(:cache_client, :env) || Application.get_env(:redis_mutex, :env)
    opts = [strategy: :one_for_one, name: RedisMutex.Supervisor]
    Supervisor.start_link(children(env), opts)
  end

  def children(:test) do
    load_redis_tests = System.get_env("REDIS_TESTS")
    if load_redis_tests != nil, do: children(:non_test_env), else: []
  end

  def children(_env) do
    redis_url = Application.get_env(:redis_mutex, :redis_url)

    [{RedisMutex.Connection, [:redis_mutex_connection, redis_url]}]
  end
end
