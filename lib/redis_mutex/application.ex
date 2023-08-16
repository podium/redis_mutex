defmodule RedisMutex.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
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
    redix_config = Application.get_env(:redis_mutex, :redix_config)

    opts = build_opts(redis_url, redix_config)

    [{RedisMutex.Connection, opts}]
  end

  defp build_opts(nil, nil) do
    raise RedisMutex.Error,
      message: ":redis_mutex config missing: must specify :redis_url or :redix_config"
  end

  defp build_opts(url, nil) when is_binary(url), do: [:redis_mutex_connection, url]
  defp build_opts(nil, opts) when is_list(opts), do: [:redis_mutex_connection, opts]

  defp build_opts(_url, _opts) do
    raise RedisMutex.Error,
      message: ":redis_mutex config must be either :redis_url or :redix_config, not both"
  end
end
