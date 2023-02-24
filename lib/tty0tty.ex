defmodule TTY0TTY do
  @moduledoc """
  `tty0tty` creates 2 pseudo-ttys that are connected together allowing you to
  run unit tests which use serial ports (like [`Circuits.UART`](https://github.com/elixir-circuits/circuits_uart))
  without the need for external hardware of adapters.

  ```elixir
  defmodule SerialTest do
    use ExUnit.Case, async: true

    test "can open a serial port" do
      {:ok, uart} = Circuits.UART.start_link()

      port_name = "/tmp/dummy1"

      # Open serial port before use
      {:ok, _port_sup} = TTY0TTY.open(port_name)

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
      {:ok, _port_sup} = TTY0TTY.open(port_name)

      assert :ok = Cicuits.UART.open(uart, port_name)

      File.write!([port_name, "-twin"], "howdy!")

      assert_receive {:circuits_uart, ^port_name, "howdy!"}
    end
  end
  ```
  """

  @doc """
  Open a null modem at the specified device path

  Note: Some systems heavily restrict the `/dev` path and attempting to open
  a device there would fail without elevated privileges. Consider opening
  devices in other places with user access, such as `/tmp` or `/mnt`
  """
  @spec open(String.t(), keyword()) :: :ok
  def open(dev_path, opts \\ []) do
    twin = dev_path <> "-twin"
    tty0tty = Application.app_dir(:tty0tty, ["priv", "tty0tty"])

    cmd = [tty0tty, [dev_path, twin], opts]
    sup_opts = [strategy: :one_for_one, name: via_name(dev_path)]

    case Supervisor.start_link([{MuonTrap.Daemon, cmd}], sup_opts) do
      {:error, {:already_started, _p}} -> :ok
      {:ok, _} -> :ok
      result -> raise "Failed to open tty0tty! - #{inspect(result)}"
    end
  end

  @doc """
  Close an open tty0tty path
  """
  @spec close(String.t() | Supervisor.supervisor()) :: :ok
  def close(dev_path) when is_binary(dev_path) do
    close(via_name(dev_path))
  end

  def close(dev), do: Supervisor.stop(dev)

  @doc """
  List all the currently open tty0tty processes
  """
  @spec list() :: [{String.t(), pid()}]
  def list() do
    Registry.select(Devices, [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
  end

  @doc """
  Lookup where the tty0tty process is
  """
  @spec whereis(String.t()) :: pid() | nil
  def whereis(dev_path) when is_binary(dev_path) do
    case Registry.lookup(Devices, dev_path) do
      [{p, _}] -> p
      [] -> nil
    end
  end

  defp via_name(dev_path) do
    {:via, Registry, {Devices, dev_path}}
  end
end
