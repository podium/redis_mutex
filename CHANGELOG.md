# CHANGELOG

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
