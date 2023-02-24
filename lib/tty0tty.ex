defmodule TTY0TTY do
  @doc """
  Open a null modem at the specified device path
  """
  @spec open(String.t(), keyword()) :: Supervisor.on_start()
  def open(dev_path, opts \\ []) do
    twin = dev_path <> "-twin"
    tty0tty = Application.app_dir(:tty0tty, ["priv", "tty0tty"])

    cmd = [tty0tty, [dev_path, twin], opts]
    sup_opts = [strategy: :one_for_one, name: via_name(dev_path)]

    case Supervisor.start_link([{MuonTrap.Daemon, cmd}], sup_opts) do
      {:error, {:already_started, p}} -> {:ok, p}
      result -> result
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
