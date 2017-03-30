defmodule RedisMutex do
  use Application

  @moduledoc """
  An Elixir library for using Redis locks

  ## Setup


  1. Add `redis_mutex` to your list of dependencies in `mix.exs`:

    def deps do
      [{:redis_mutex, "~> 0.1.0"}]
    end

  2. Ensure `redis_mutex` is started before your application:

    def application do
      [applications: [:redis_mutex]]
    end

  3. You'll need to set the `redis_url` in your `config.exs`

    config :redis_mutex, redis_url: {:system, "REDIS_URL"}

  4. Call `use RedisMutex` in the module you want to use the lock.

    defmodule PossumLodge do

      def get_oath do
        "Quando omni flunkus moritati"
      end
    end


    With a Redis lock:

    defmodule PossumLodge do
      use RedisMutex

      def get_oath do
        with_lock("my_key") do
          "Quando omni flunkus moritati"
        end
      end
    end
  """

  @doc """
  The start function will get the redis_url from the config and connect to the
  Redis instance.
  """
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
