# CHANGELOG

## 1.0.0 (2024-02-12)

### Changed

**Breaking changes**
- `RedisMutex` no longer starts as its own application. Instead, it can re-use an existing Redis connection
  or be started in your application's supervision tree. Here is an example of starting it in an application's
  supervision tree:
```elixir
  @impl Application
  def start(_type, _args) do
    children = other_children() ++ [{RedisMutex, redis_url: System.get_env("REDIS_URL")}]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
```
  Please see the README for more details.
- `use RedisMutex` replaced in favor of calling `RedisMutex.with_lock/3` directly
- `with_lock` changed to take a function argument instead of a do block to perform
- `with_lock` changed to take a keyword list of options instead of optional `timeout` and `expiry` arguments


## 0.6.0 (2023-11-08)

### Changed
- support for Elixir 1.15. Bump some package dependencies
- change to use Uniq lib rather than the unmaintained elixir_uuid

## 0.5.0 (2023-08-16)

### Changed

* Support custom redix opts by @brentjanderson (#23)
* Updates some of the dependencies
## 0.4.0 (2022-11-22)

### Changed

* Use Redix instead of ExRedis as the adapter
* Bump Elixir version to 1.11
* Retool the internals of the library to use modern Elixir conventions
* Updates to the test suite so it can run against live redis in test
