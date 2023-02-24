defmodule TTY0TTY.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Devices}
    ]

    opts = [strategy: :one_for_one, name: TTY0TTY.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
