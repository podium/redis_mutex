defmodule RedisMutex.Supervisor do
  @moduledoc """
  The supervisor module for RedisMutex.
  """
  use Supervisor

  alias RedisMutex.ConfigParser

  @type start_options :: [
          name: module(),
          otp_app: atom(),
          lock_module: module(),
          redis_url: String.t(),
          redix_config: RedisMutex.connection_options()
        ]

  @spec start_link(atom(), module(), module(), [start_options()]) :: Supervisor.on_start()
  def start_link(otp_app, module, lock_module, opts)
      when is_atom(otp_app) and is_atom(lock_module) and
             is_list(opts) do
    Supervisor.start_link(__MODULE__, {otp_app, module, lock_module, opts}, name: __MODULE__)
  end

  @impl Supervisor
  @spec init({atom(), module(), module(), start_options()}) ::
          {:ok, {Supervisor.sup_flags(), [Supervisor.child_spec()]}}
  def init({otp_app, module, lock_module, opts}) do
    parsed_opts = ConfigParser.parse(otp_app, module, opts)

    children = [
      {lock_module, [parsed_opts]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
