defmodule RedisMutex.Supervisor do
  @moduledoc """
  The supervisor module for RedisMutex.
  """
  use Supervisor

  @type start_options :: {:redis_url, String.t()} | RedisMutex.connection_options()

  @spec start_link(module(), start_options()) :: Supervisor.on_start()
  def start_link(lock_module, opts) when is_atom(lock_module) and is_list(opts) do
    Supervisor.start_link(__MODULE__, {lock_module, opts}, name: __MODULE__)
  end

  @impl Supervisor
  @spec init({module(), start_options()}) ::
          {:ok, {Supervisor.sup_flags(), [Supervisor.child_spec()]}}
  def init({lock_module, opts}) do
    children = [
      {lock_module, [opts]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
