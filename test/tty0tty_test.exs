# SPDX-FileCopyrightText: 2023 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0

defmodule TTY0TTYTest do
  use ExUnit.Case
  doctest TTY0TTY

  setup context do
    name = Base.encode64(to_string(context.test), padding: false)

    # Circuits.UART only allows 64 bytes for the device name. Let's call
    # this unique enough and make sure we don't go over
    {dev_path, _rem} = String.split_at("/tmp/tty0tty-test-#{name}", 64)

    %{dev_path: dev_path}
  end

  test "can open a port", %{dev_path: dev_path} do
    assert :ok = TTY0TTY.open(dev_path)

    {:ok, uart} = Circuits.UART.start_link()

    assert :ok = Circuits.UART.open(uart, dev_path)
    assert :ok = File.write([dev_path, "-twin"], "Howdy!")

    assert_receive {:circuits_uart, ^dev_path, "Howdy!"}

    assert [{^dev_path, p}] = TTY0TTY.list()
    assert is_pid(p)

    assert ^p = TTY0TTY.whereis(dev_path)
    assert :ok = TTY0TTY.close(dev_path)
    refute Process.alive?(p)
  end

  test "port and twin fail to create", context do
    assert {:error, :enoent} = TTY0TTY.open(context.dev_path, timeout: 1)
  end
end
