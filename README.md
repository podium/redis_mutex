# RedisMutex

[![Build Status](https://github.com/podium/redis_mutex/actions/workflows/ci.yml/badge.svg)](https://github.com/podium/redis_mutex/actions/workflows/ci.yml) [![Hex.pm](https://img.shields.io/hexpm/v/redis_mutex.svg)](https://hex.pm/packages/redis_mutex) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/redis_mutex)
[![Total Download](https://img.shields.io/hexpm/dt/redis_mutex.svg)](https://hex.pm/packages/redis_mutex)
[![License](https://img.shields.io/hexpm/l/redis_mutex.svg)](https://github.com/podium/redis_mutex/blob/master/LICENSE.md)

RedisMutex is a library for creating a Redis lock for a single Redis instance.

## Installation

The package can be installed by adding `redis_mutex`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:redis_mutex, "~> 1.0"}
  ]
end
```


## Usage

1. Set the `redis_url` in your `config.exs`

```elixir
config :redis_mutex, redis_url: {:system, "REDIS_URL"}
```

Alternatively, pass [`redix` options](https://hexdocs.pm/redix/Redix.html#start_link/1-options) directly:

```elixir
config :redis_mutex,
  redix_config: [
    host: "example.com",
    port: 9999,
    ssl: true,
    socket_opts: [
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ]
  ]

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