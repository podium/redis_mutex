# RedisMutex

RedisMutex is a library for creating a Redis lock for a single Redis instance.

## Installation

[From Hex](https://hex.pm/docs/publish), the package can be installed as:

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
