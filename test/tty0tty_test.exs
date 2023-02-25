# SPDX-FileCopyrightText: 2023 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0

defmodule TTY0TTYTest do
  use ExUnit.Case
  doctest TTY0TTY

  test "can open a port" do
    port = "/tmp/tty0tty-testing"
    assert :ok = TTY0TTY.open(port)

    assert :ok = File.write(port, "Howdy!")
    assert :ok = File.write([port, "-twin"], "Partner!")
  end
end
