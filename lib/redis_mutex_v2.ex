defmodule RedisMutexV2 do
  @moduledoc """
  An Elixir library for using Redis locks.
  """
  @type socket_options :: [
          customize_hostname_check: [
            match_fun: function()
          ]
        ]

  @type connection_options :: [
          host: String.t(),
          port: non_neg_integer(),
          ssl: boolean(),
          socket_opts: socket_options()
        ]

  @type start_options :: {:redis_url, String.t()} | {:redix_config, connection_options()}

  @type using_options :: {:otp_app, atom()}

  @default_lock_module RedisMutex.LockV2

  @spec __using__([using_options()]) :: term()
  defmacro __using__(opts) do
    {otp_app, otp_app_opts} = Keyword.pop(opts, :otp_app)

    lock_module =
      otp_app_opts[:lock_module] ||
        Application.get_env(otp_app, __MODULE__)[:lock_module] ||
        @default_lock_module

    quote do
      import unquote(lock_module), warn: false

      def child_spec(opts \\ []) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      @spec start_link([RedisMutexV2.start_options()]) :: Supervisor.on_start()
      def start_link(opts \\ []) do
        app = unquote(otp_app)
        the_lock_module = unquote(lock_module)

        RedisMutex.Supervisor.start_link(
          app,
          __MODULE__,
          the_lock_module,
          opts ++ [name: __MODULE__]
        )
      end
    end
  end
end
