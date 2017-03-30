# RedisMutex

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `redis_mutex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:redis_mutex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `redis_mutex` is started before your application:

    ```elixir
    def application do
      [applications: [:redis_mutex]]
    end
    ```

