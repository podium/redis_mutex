defmodule RedisMutex do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    redis_url = Application.get_env(:redis_mutex, :redis_url)

    children = [
      worker(RedisMutex.Connection, [:redis_mutex_connection, redis_url])
    ]

    opts = [strategy: :one_for_one, name: RedisMutex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmacro __using__(_opts) do
    quote do
      import RedisMutex.Lock, warn: false
    end
  end
end
