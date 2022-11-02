defmodule RedisMutex do
  @moduledoc """
  An Elixir library for using Redis locks

  ## Setup


  1. Add `redis_mutex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:redis_mutex, "~> 0.4.0"}]
    end
    ```

  2. Ensure `redis_mutex` is started before your application:

    ```elixir
    def application do
      [applications: [:redis_mutex]]
    end
    ```

  3. Set the `redis_url` in your `config.exs`

    ```elixir
    config :redis_mutex, redis_url: {:system, "REDIS_URL"}
    ```

  4. Call `use RedisMutex` in the module you want to use the lock.

    ```elixir
    defmodule PossumLodge do

      def get_oath do
        "Quando omni flunkus moritati"
      end
    end
    ```

    With a Redis lock:

    ```elixir
    defmodule PossumLodge do
      use RedisMutex

      def get_oath do
        with_lock("my_key") do
          "Quando omni flunkus moritati"
        end
      end
    end
    ```
  """

  defmacro __using__(opts) do
    lock_module =
      if Keyword.keyword?(opts),
        do:
          Keyword.get(
            opts,
            :lock_module,
            Application.get_env(:redis_mutex, :lock_module, RedisMutex.Lock)
          )

    quote do
      import unquote(lock_module), warn: false
    end
  end
end
