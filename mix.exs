defmodule PhxInPlace.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phx_in_place,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 3.2", only: :test},
      {:phoenix_html, "~> 2.10"},
      {:number, "~> 0.5.5"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description do
    """
      Library for generating inline editable fields with minimal configuration.
    """
  end

  defp package do
    [
      maintainers: ["Chris Adair"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/cjwadair/phx_in_place"},
      files: ~w(lib priv package.json README.md)
    ]
  end
end
