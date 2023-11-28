# TTY0TTY

[![REUSE status](https://api.reuse.software/badge/github.com/jjcarstens/tty0tty)](https://api.reuse.software/info/github.com/jjcarstens/tty0tty)

Elixir port for [`tty0tty` null modem emulator](https://github.com/freemed/tty0tty)

## Use

This library is almost exclusively for testing purposes. `tty0tty` creates 2
pseudo-ttys that are connected together allowing you to run unit tests which
use serial ports (like [`Circuits.UART`](https://github.com/elixir-circuits/circuits_uart))
without the need for external hardware of adapters.

```elixir
defmodule SerialTest do
  use ExUnit.Case, async: true

  test "can open a serial port" do
    {:ok, uart} = Circuits.UART.start_link()

    port_name = "/tmp/dummy1"

    # Open serial port before use
    :ok = TTY0TTY.open(port_name)

    assert :ok = Cicuits.UART.open(uart, port_name)
  end
end
```

Under the hood, `TTY0TTY.open/2` opens 2 devices (`<port_name>`, and
`<port_name>-twin`) and connects their TX <-> RX to emulate the serial
connection. This allows you to also verifying reading serial data by sending
data to the connected twin port:


```elixir
defmodule SerialTest do
  use ExUnit.Case, async: true

  test "can read a serial port" do
    {:ok, uart} = Circuits.UART.start_link()

    port_name = "/tmp/dummy1"

    # Open serial port before use
    :ok = TTY0TTY.open(port_name)

    assert :ok = Cicuits.UART.open(uart, port_name)

    File.write!([port_name, "-twin"], "howdy!")

    assert_receive {:circuits_uart, ^port_name, "howdy!"}
  end
end
```
