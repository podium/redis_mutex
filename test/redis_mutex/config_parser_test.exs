defmodule RedisMutex.ConfigParserTest do
  use ExUnit.Case, async: true

  alias RedisMutex.ConfigParser

  describe "parse/3" do
    setup do
      existing_config = Application.get_env(:my_app, RedisMutex.ConfigParserTest)

      app_config = [
        lock_module: RedisMutex.ConfigParserTest.ConfigLockModule,
        redis_url: "redis://localhost:6379"
      ]

      Application.put_env(:my_app, RedisMutex.ConfigParserTest, app_config)

      on_exit(fn ->
        Application.put_env(
          :my_app,
          RedisMutex.ConfigParserTest,
          existing_config
        )
      end)

      [app_config: app_config]
    end

    test "returns the lock module from the config when none is passed in the opts", %{
      app_config: app_config
    } do
      opts = []

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)

      assert Keyword.get(parsed_opts, :lock_module) == Keyword.get(app_config, :lock_module)
    end

    test "returns the lock module passed in the opts" do
      opts = [
        lock_module: RedisMutex.Lock.Redix
      ]

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)

      assert Keyword.get(parsed_opts, :lock_module) == RedisMutex.Lock.Redix
    end

    test "returns the redis_url from the config when none is passed in the opts", %{
      app_config: app_config
    } do
      opts = []

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)

      assert Keyword.get(parsed_opts, :redis_url) == Keyword.get(app_config, :redis_url)
    end

    test "returns the redis_url passed in the opts" do
      opts = [
        redis_url: "redis://localhost:6381"
      ]

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)

      assert Keyword.get(parsed_opts, :redis_url) == "redis://localhost:6381"
    end

    test "returns the redix_config passed in the opts" do
      opts = [
        redix_config: [
          host: "localhost",
          port: 6381,
          ssl: true,
          socket_opts: []
        ]
      ]

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)

      assert Keyword.has_key?(parsed_opts, :redix_config)
      assert parsed_opts[:redix_config] == opts[:redix_config]
    end

    test "should not include the redis_url if a redix_config is present in the opts" do
      opts = [
        redix_config: [
          host: "localhost",
          port: 6381,
          ssl: true,
          socket_opts: []
        ]
      ]

      parsed_opts = ConfigParser.parse(:my_app, RedisMutex.ConfigParserTest, opts)
      dbg(parsed_opts)

      refute Keyword.has_key?(parsed_opts, :redis_url)
    end
  end
end
