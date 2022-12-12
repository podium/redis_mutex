defmodule RedisMutex.Mixfile do
  use Mix.Project

  @source_url "https://github.com/podium/redis_mutex"
  @version "0.4.0"

  def project do
    [
      app: :redis_mutex,
      version: @version,
      elixir: "~> 1.11",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description:
        "RedisMutex is a library for creating a Redis lock for a single Redis instance",
      source_url: "https://github.com/podium/redis_mutex",
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [summary: [threshold: 90]]
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {RedisMutex.Application, []}]
  end

  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:elixir_uuid, "~> 1.2"},

      # Dev and test dependencies
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:ex_doc, "~> 0.29", only: :dev}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "CHANGELOG.md",
        {:"README.md", title: "Readme"}
      ],
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Podium"],
      links: %{
        "GitHub" => "https://github.com/podium/redis_mutex",
        "Docs" => "https://hexdocs.pm/redis_mutex/#{@version}/",
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end
end
