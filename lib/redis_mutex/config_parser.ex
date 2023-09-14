defmodule RedisMutex.ConfigParser do
  @moduledoc """
  Parses the config for RedisMutex.
  """

  @doc """
  Parses the configuration options for starting RedisMutex. Options in the `opts`
  argument take predence over options in the config.

  ## Example config
        config :my_app, RedisMutex.MyModule,
          lock_module: RedisMutex.MyLockModule,
          redis_url: "redis://localhost:6379"
  """
  @spec parse(atom(), module(), RedisMutex.Supervisor.start_options()) ::
          RedisMutex.Supervisor.start_options()
  def parse(otp_app, module, opts) do
    config_opts = Application.get_env(otp_app, module, [])

    {lock_module, config_opts} = Keyword.pop(config_opts, :lock_module)
    {redis_url, _config_opts} = Keyword.pop(config_opts, :redis_url)

    opts
    |> update_lock_module(lock_module)
    |> update_redis_url(redis_url)
  end

  @spec update_lock_module(RedisMutex.Supervisor.start_options(), module()) ::
          RedisMutex.Supervisor.start_options()
  defp update_lock_module(opts, lock_module) do
    Keyword.put_new(opts, :lock_module, lock_module)
  end

  @spec update_redis_url(RedisMutex.Supervisor.start_options(), String.t()) ::
          RedisMutex.Supervisor.start_options()
  def update_redis_url(opts, redis_url) do
    if Keyword.has_key?(opts, :redix_config) do
      opts
    else
      Keyword.put_new(opts, :redis_url, redis_url)
    end
  end
end
