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

  ## Custom Redix configuration

  Instead of passing a `redis_url` to configure the `Redix` client, use `redix_config`
  to pass any of the [configuration options available to Redix](https://hexdocs.pm/redix/Redix.html#start_link/1-options):

  ```elixir
  config :redis_mutex, redix_config: [
    host: "example.com", port: 9999, ssl: true,
    socket_opts: [
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ]
  ]
  ```

  Only one of `:redix_config` and `:redis_url` can be used at a time.
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
