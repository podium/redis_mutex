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

## Upgrading from version 0.X to version 1.X

Version 1.0.0 of `RedisMutex` changes how `RedisMutex` is started and how `with_lock` is used. Key changes include:

1. `RedisMutex` no longer runs as its own application.
   1. If you need or want to set up a Redix connection specifically for `RedisMutex`, it must be added to your application's supervision tree.
   2. If you want to re-use an existing Redis connection via Redix, it does not need adding to your application's supervision tree.
2. Configuration for `RedisMutex` (in your application's `config` files) has changed.
3. Using `RedisMutex`'s `with_lock` is no longer done via `use RedisMutex`. Instead, your application must call
   the function `RedisMutex.with_lock/3`.
4. The code you want to execute in `RedisMutex.with_lock/3` is passed in a zero-arity function instead of in a `do` 
   block.
5. Timeout and expiry options for `RedisMutex.with_lock/3` are optionally provided in a keyword list as the last
   argument to `RedisMutex.with_lock/3`.
6. Callbacks are defined for `RedisMutex`'s functions to allow for doubles to be used in testing.

In order to upgrade to version 1.X, you will need to:
1. Add `RedisMutex` to your application's supervision tree unless you are using an existing Redis connection via Redix.
2. Update your config files to match the new configuration options if you are adding `RedisMutex` to the supervision tree.
3. Remove use of `use RedisMutex` in favor of `RedisMutex.with_lock/3`.
4. Replace the `do` block with a zero-arity function in your calls to `RedisMutex.with_lock/3`.
5. Move any timeout or expiry arguments into a keyword list as the final argument to `RedisMutex.with_lock/3`.
6. If you are not running Redis when you run your unit tests, update your test suite to use a double 
   that handles `RedisMutex`'s updated functions.

Please see the [Usage](#usage) section for more details.

## Usage

`RedisMutex` offers the user flexibility in how it is used. If you need to start a named connection to Redis
for a mutex, you can do so via `RedisMutex`.`RedisMutex` offers a default connection name when starting 
your connection to Redis. This is the simplest way to use `RedisMutex`, and it is the default.

If you want to customize the name used for that connection, you can specify a 
name to use for the connection.

If you already have a named connection to Redis and want to re-use that, you can do that as well.

### Starting a new connection to Redis

In order to start a connection for `RedisMutex`, you need to set options in your configuration and
add `RedisMutex` to your application's supervision tree.

#### Using `RedisMutex`'s defaults

By default, `RedisMutex` will use `RedisMutex` as the name for setting up a connection to Redis.

#### Setting options for starting a connection
Set the `options` in your `config.exs`. The options can be a `redis_url` or a set of options for 
Redis. See `RedisMutex.start_options` for details.

##### Example configuration with a `redis_url` and the default name `RedisMutex`

```elixir
config :redis_mutex, RedisMutex, redis_url: System.get_env("REDIS_URL")
```

##### Example configuration with a keyword list of connection options and the default name `RedisMutesx`

```elixir
config :redis_mutex, RedisMutex,
  host: "localhost",
  port: 6379
```
#### Adding `RedisMutex` to your application's supervision tree with `RedisMutex`'s defaults

If you want to use the defaults, you can simply add `RedisMutex` to your application's supervision tree.

```elixir
  @impl Application
  def start(_type, _args) do
    children = other_children() ++ [RedisMutex]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```

#### Using a custom connection name

If you want to start a connection with a name other than `RedisMutex`, you should specify the name you
want to use when defining the configuration for `RedisMutex` and when adding the `RedisMutex` to your
application's supervision tree. You will also need to provide this name as an option to the lock function
when using `RedisMutex`.

#### Setting options for starting a connection with a custom name
Set the `options` in your `config.exs`. `redis_options` can be a `redis_url` or a set of options for Redis. See
`RedisMutex.start_options` for details.

##### Example configuration with a `redis_url` and the connection name `MyApp.Mutex`

```elixir
config :redis_mutex, MyApp.Mutex, redis_url: System.get_env("REDIS_URL")
```

##### Example configuration with a keyword list of connection options and the connection name `MyApp.Mutex`

```elixir
config :redis_mutex, MyApp.Mutex,
  host: "localhost",
  port: 6379
```
#### Adding `RedisMutex` to your application's supervision tree with a custom connection name

In order to specify the connection name, include it as an option when adding `RedisMutex` to your
application's supervision tree.

```elixir
  @impl Application
  def start(_type, _args) do
    children = other_children() ++ [{RedisMutex, name: MyApp.Mutex}]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```

### Using an existing named connection to Redis

If you have a named connection to Redis that you want to re-use, you do not need to add `RedisMutex`
to your application's supervision tree. You can supply the name of the connection as an options
when calling `RedisMutex`'s `with_lock/3` function. See the documentation for the `with_lock/3` function
below for more details.

### Wrapping `RedisMutex`

If you are using a custom connection name and want to simplify the use of `RedisMutex`, you can
write a wrapper module for `RedisMutex` and add that module to your application's supervision tree.

#### Sample wrapper module
```elixir
defmodule MyApp.Mutex do

  @redis_mutex Application.compile_env(:my_app, :redis_mutex, RedisMutex)
  
  def child_spec(_opts) do
    @redis_mutex.child_spec(name: MyApp.Mutex) 
  end
  
  def start_link(start_options) do
    @redis_mutex.start_link(start_options)
  end
  
  def with_lock(key, opts, fun) do
    lock_options = Keyword.merge(opts, name: MyApp.Mutex)
    @redis_mutex.with_lock(key, fun, lock_options)
  end
end
```

#### Configuration for the wrapper module
```elixir
config :redis_mutex, MyApp.Mutex, redis_url: System.get_env("REDIS_URL")
```

#### Adding the wrapper module to the supervision tree 
```elixir
  @impl Application
  def start(_type, _args) do
    children = other_children() ++ [MyApp.Mutex]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```

### Using `RedisMutex`

Call `RedisMutex`'s `with_lock/3` function to lock critical parts of your code. `with_lock/3` must be
provided with a `key` argument and a zero-arity function argument to call. This function will be called
if and when the lock is acquired.

```elixir
defmodule PossumLodge do

  @redis_mutex Application.compile_env(:my_app, :redis_mutex, RedisMutex)
  
  def get_oauth do
    @redis_mutex.with_lock("my_key", fn ->
      "Quando omni flunkus moritati"
    end)
  end
end
```

`with_lock/3` also allows setting options, including a name for the connection, a timeout and an
expiry, both in milliseconds. If you have specified a custom connection name or are re-using an
existing named connection to redis, the name of that connection must be included in the options
when calling `with_lock/3`.

```elixir
defmodule PossumLodge do

  @redis_mutex Application.compile_env(:my_app, :redis_mutex, RedisMutex)
  @mutex_options [name: MyApp.Mutex, timeout: 500, expiry: 1_000]
  
  def get_oauth do
    @redis_mutex.with_lock(
      "my_key", 
      fn -> "Quando omni flunkus moritati" end,
      @mutex_options
      )
  end
end
```


## Testing your application with `RedisMutex`

### Testing your application with Redis running

If you are running Redis when you are running your test suite, simply having the `redis_mutex` config set and 
running the default command works:

```
mix test
```

### Testing your application without an instance of Redis running

If you want to test your application without an instance of Redis running, you will need to define a double for
`RedisMutex`. `RedisMutex` defines callbacks for `child_spec/1`, `start_link/1`, `with_lock/2` and `with_lock/3`.

#### Define a mock for `RedisMutex`

If you are using `Mox`, you can define the mock along with your other mocks.

```
Mox.defmock(RedisMutexMock, for: RedisMutex)
```
