defmodule RedisMutex.ConfigParser do
  @moduledoc """
  Parses the config for RedisMutex.
  """

  @doc """
  Parses the configuration options for starting RedisMutex. Options in the `opts`
  argument take predence over options in the config.

  ## Example config
        config :my_app, RedisMutex.MyModule,
          redis_url: "redis://localhost:6379"
  """
  @spec parse(atom(), module(), RedisMutex.Supervisor.start_options()) ::
          RedisMutex.Supervisor.start_options()
  def parse(otp_app, module, opts) do
    config_opts = Application.get_env(otp_app, module, [])

    {redis_url, _config_opts} = Keyword.pop(config_opts, :redis_url)

    if Keyword.has_key?(opts, :redix_config) do
      opts
    else
      Keyword.put_new(opts, :redis_url, redis_url)
    end
  end
end
