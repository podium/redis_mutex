defmodule RedisMutex.ApplicationTest do
  @moduledoc """
  Tests various configuration scenarios
  """

  use ExUnit.Case, async: false
  doctest RedisMutex

  setup do
    Application.put_env(:redis_mutex, :redis_url, nil)
    Application.put_env(:redis_mutex, :redix_config, nil)
  end

  describe "child_spec configuration" do
    test "can pass just a redis URI" do
      Application.put_env(:redis_mutex, :redis_url, "redis://localhost:6379/")

      assert [{RedisMutex.Connection, [:redis_mutex_connection, "redis://localhost:6379/"]}] =
               RedisMutex.Application.children(:some_env)
    end

    test "can pass just redix opts" do
      Application.put_env(:redis_mutex, :redix_config,
        host: "localhost",
        port: 6379
      )

      assert [{RedisMutex.Connection, [:redis_mutex_connection, [host: "localhost", port: 6379]]}] =
               RedisMutex.Application.children(:some_env)
    end

    test "cannot pass both URI and redix opts" do
      assert_raise RedisMutex.Error, fn ->
        Application.put_env(:redis_mutex, :redis_url, "redis://localhost:6379/")

        Application.put_env(:redis_mutex, :redix_config,
          host: "localhost",
          port: 6379
        )

        RedisMutex.Application.children(:some_env)
      end
    end

    test "must set either URI or redix opts" do
      assert_raise RedisMutex.Error, fn ->
        Application.put_env(:redis_mutex, :redis_url, nil)
        Application.put_env(:redis_mutex, :redix_config, nil)
        RedisMutex.Application.children(:some_env)
      end
    end
  end
end
