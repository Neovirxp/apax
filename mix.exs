defmodule Apax.Mixfile do
  use Mix.Project

  def project do
    [app: :apax,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:sweet_xml, "~> 0.6.1"}
    ]
  end

  defp description do
    """
    Amazon Product Advertising Client for Elixir
    """
  end

  defp package do
    [name: :ampex,
     maintainers: ["Neovirxp"],
     licenses: ["Apache 2.0"],
     files: ["lib", "mix.exs", "README*"],
     links: %{"GitHub" => "https://github.com/neovirxp/apax"}]
  end
end
