# SPDX-FileCopyrightText: 2023 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0

defmodule TTY0TTY.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Devices},
      TTY0TTY
    ]

    opts = [strategy: :one_for_one, name: TTY0TTY.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
