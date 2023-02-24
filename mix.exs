defmodule TTY0TTY.MixProject do
  use Mix.Project

  def project do
    [
      app: :tty0tty,
      version: "0.1.0",
      elixir: "~> 1.14",
      compilers: [:elixir_make | Mix.compilers()],
      deps: deps(),
      make_clean: ["clean"],
      make_targets: ["all"],
      start_permanent: Mix.env() == :prod
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TTY0TTY.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.7", runtime: false},
      {:muontrap, "~> 1.0"}
    ]
  end
end
