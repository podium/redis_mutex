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

### Adding `RedisMutex` to your application's supervision tree

Add `RedisMutex` to your application's supervision tree.

```elixir
  @impl Application
  def start(_type, _args) do
    children = [other_children() | RedisMutex]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```

If you do not have an instance of redis running when you run your test suite, exclude `RedisMutex` from your
application's supervision tree in test.

```elixir
  @impl Application
  def start(_type, _args) do
    children =
      if Mix.env() == :test do
        other_children()
      else
        [other_children() | RedisMutex]
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```

### Setting options for starting
Set the `redis_options` in your `config.exs`. `redis_options` can be a `redis_url` or a set of options for Redis. See 
`RedisMutex.start_options` for details.

#### Example with a `redis_url`

```elixir
config :redis_mutex, 
  redis_options: [
  redis_url: System.get_env("REDIS_URL")
  ]
```

#### Example with a keyword list of connection options

```elixir
config :redis_mutex,
  redis_options: [
    host: "localhost",
    port: 6379
  ]
```

### Using `RedisMutex`
Call `use RedisMutex` in the module you want to use the lock and use `with_lock` to
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

`with_lock` also allows setting an optional timeout and expiry in milliseconds.

```elixir
defmodule PossumLodge do
  use RedisMutex

  def get_oauth do
    with_lock("my_key", 2000, 4000) do
      "Quando omni flunkus moritati"
    end
  end
end
```


## Testing your application with `RedisMutex`

### Testing your application with Redis running

If you are running Redis when you are running your test suite, simply having the `redis_mutex` config set and running the
default command works:

```
mix test
```

### Testing your application without an instance of Redis running

If you want to test your application without an instance of Redis running, you will need to define a double for
`RedisMutex.Lock` and specify that double as the `lock_module` in the `redis_mutex` config in `config/test.exs`. This
could be a module that implements the behaviour of `RedisMutex.Lock` or it could be a double using `Mox` or another
library for test doubles. The examples here assume the use of `Mox`.

#### Define a mock for `RedisMutex.Lock`

If you are using `Mox`, you can define the mock along with your other mocks.

```
Mox.defmock(RedisMutexLockMock, for: RedisMutex.Lock)
```

#### Set the `lock_module` in your application's configuration

In `config/test.exs`, set your mock as the `lock_module` for `redis_mutex`.

```
config :redis_mutex,
  lock_module: RedisMutexLockMock
```

#### Define stubs for the lock module's `with_lock` 

Depending on whether or not you set a timeout and/or expiry when using `with_lock`, define one or more stubs that
fit the arity of `with_lock` that you are using.

```elixir
    stub(RedisMutexLockMock, :with_lock, fn _key, do_clause ->
      [do: block_value] =
        quote do
          unquote(do_clause)
        end

      block_value
    end)

    stub(RedisMutexLockMock, :with_lock, fn _key, _timeout, do_clause ->
      [do: block_value] =
        quote do
          unquote(do_clause)
        end

      block_value
    end)

    stub(RedisMutexLockMock, :with_lock, fn _key, _timeout, _expiry, do_clause ->
      [do: block_value] =
        quote do
          unquote(do_clause)
        end

      block_value
    end)
```

The example stubs will return the value in the do block that your application provides to `with_lock`.

## Testing `RedisMutex`

To run the portion of the test suite that does not rely on Redis, run the default command:
```
mix test
```

To run the full test suite including those portions that depend on a Redis instance running
and being configured in `config/test.exs`, run the following command:
```
mix test --include=redis_dependent
```
