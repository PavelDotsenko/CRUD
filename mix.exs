defmodule CRUD.MixProject do
  use Mix.Project

  def project do
    [
      app: :crud,
      version: "1.0.1",
      elixir: "~> 1.6",
      deps: deps(),
      description: "A set of tools for simplified database access",
      package: package(),
      elixirc_paths: ["lib"]
    ]
  end

  def application, do: [extra_applications: []]

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", ".gitignore"],
      maintainers: ["Pavel Dotsenko"],
      licenses: ["Apache 2.0"],
      links: %{
        GitHub: "https://github.com/PavelDotsenko/CRUD",
        Issues: "https://github.com/PavelDotsenko/CRUD/issues"
      }
    ]
  end
end
