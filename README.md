# RedisMutex

RedisMutex is a library for creating a Redis lock for a single Redis instance.

## Installation

The package can be installed by adding `redis_mutex`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:redis_mutex, "~> 0.4.0"}
  ]
end
```


## Usage

1. Set the `redis_url` in your `config.exs`

```elixir
config :redis_mutex, redis_url: {:system, "REDIS_URL"}
```

2. Call `use RedisMutex` in the module you want to use the lock and use `with_lock` to
lock critical parts of your code.

```elixir
defmodule PossumLodge do
  use RedisMutex

  def get_oauth do
    with_lock("my_key") do
      "Quando omni flunkus moritati"
    end
  end
end
```

## Tests
To run the portion of the test suite that does not rely on Redis, run the default command:
```
mix test
```

To run the full test suite including those portions that depend on a Redis instance running
and being configured in `config/test.exs`, run the following command:
```
REDIS_TESTS=true mix test --include=redis_dependent
```