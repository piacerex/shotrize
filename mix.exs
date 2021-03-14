defmodule Shotrize.MixProject do
  use Mix.Project

  def project do
    [
      app: :shotrize,
      version: "0.1.0",
      elixir: "~> 1.10",
      description: "Various web page generator in Phoenix(Elixir Web Framework) ",
      package: [
        maintainers: ["piacerex"],
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/piacerex/shotrize"}
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
    ]
  end
end
