defmodule RedisMutex.Mixfile do
  use Mix.Project

  def project do
    [app: :redis_mutex,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     description: description(),
     source_url: "https://github.com/podium/redis_mutex",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :timex],
     mod: {RedisMutex, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.18.1", only: :dev},
      {:exredis, "~> 0.2.5"},
      {:timex, "~> 3.1.24"},
      {:uuid, "~> 1.1.8"}
    ]
  end

  defp description do
    """
    RedisMutex is a library for creating a Redis lock for a single Redis instance.
    """
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Travis Elnicky, Jason Turner"],
      links: %{
        "GitHub" => "https://github.com/podium/redis_mutex"
      }
    ]
  end
end
