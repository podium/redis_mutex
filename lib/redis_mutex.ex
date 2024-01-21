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

  @type start_options :: {:redis_url, String.t()} | connection_options()

  @default_lock_module RedisMutex.Lock

  def child_spec(opts \\ []) do
    args = child_spec_args(opts)

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      type: :supervisor
    }
  end

  @spec start_link(Keyword.t()) :: Supervisor.on_start()
  def start_link(opts) do
    lock_module = lock_module(opts)

    options = Application.get_env(:redis_mutex, :redis_options, [])

    RedisMutex.Supervisor.start_link(
      lock_module,
      options
    )
  end

  defmacro __using__(opts \\ []) do
    lock_module = lock_module(opts)

    quote do
      import unquote(lock_module), warn: false
    end
  end

  defp child_spec_args(opts) do
    if Keyword.equal?([], opts) do
      nil
    else
      opts
    end
  end

  defp lock_module(opts) do
    case opts[:lock_module] do
      nil ->
        Application.get_env(:redis_mutex, :lock_module, @default_lock_module)

      _ ->
        opts[:lock_module]
    end
  end
end
