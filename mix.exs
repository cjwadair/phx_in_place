defmodule PhxInPlace.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phx_in_place,
      version: "0.1.3",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      deps: deps(),
      package: package(),
      docs: docs(),
      elixirc_paths: ["lib", "test/support"],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger],
    env: [tokenHandler: Phoenix.Token, updateHandler: UpdateHandler]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 3.2", only: :test},
      {:phoenix_html, "~> 2.10", only: :test},
      {:number, "~> 0.5.5"}
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
      files: ~w(lib priv CHANGELOG.md LICENSE mix.exs package.json README.md)
    ]
  end

  defp docs do
    [
      source_url: "https://github.com/cjwadair/phx_in_place",
      main: "PhxInPlace",
      extras: ["README.md"]
    ]
  end
end
