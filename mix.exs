defmodule JellyShot.Mixfile do
  use Mix.Project

  def project do
    [app: :jelly_shot,
     version: "0.0.2",
     elixir: "~> 1.7",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {JellyShot, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :timex,
        :yaml_elixir,
        :fs
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.4.0"},
     {:phoenix_pubsub, "~> 1.1"},
     {:phoenix_html, "~> 2.13"},
     {:phoenix_live_reload, "~> 1.2", only: :dev},
     {:jason, "~> 1.1"},
     {:gettext, "~> 0.16.1"},
     {:plug_cowboy, "~> 2.0"},
     {:plug, "~> 1.7"},
     {:earmark, "~> 1.3"},
     {:timex, "~> 3.4"},
     {:yaml_front_matter, "~> 0.3.0"},
     {:flow, "~> 0.14"},
     {:fs, github: "synrc/fs", manager: :rebar, override: true},
     {:excoveralls, "~> 0.10"},
     {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
   end
end
