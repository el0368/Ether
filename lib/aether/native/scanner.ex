defmodule Aether.Native.Scanner do
  @moduledoc """
  NIF Loader for the Native Scanner.
  Loads the manually compiled `scanner_nif.dll` from `priv/native`.
  """
  require Logger
  @on_load :load_nif

  def load_nif do
    # Locate the priv directory for the :aether application
    path = Application.app_dir(:aether, "priv/native/scanner_nif")
    |> String.to_charlist()

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, {:load_failed, reason}} ->
        Logger.error("Failed to load Native Scanner NIF: #{path}")
        Logger.error("Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def scan(path) do
    case scan_nif(path) do
      {:ok, binary} when is_binary(binary) ->
        {:ok, decode(binary, path)}
      error -> error
    end
  end

  def scan_raw(path) do
    scan_nif(path)
  end

  def scan_nif(_path), do: :erlang.nif_error(:nif_not_loaded)

  defp decode(binary, root, acc \\ [])
  defp decode(<<>>, _root, acc), do: Enum.reverse(acc)

  defp decode(<<type::8, len::16-little, name::binary-size(len), rest::binary>>, root, acc) do
    type_atom = case type do
      1 -> :file
      2 -> :directory
      3 -> :symlink
      _ -> :other
    end
    full_path = Path.join(root, name)
    decode(rest, root, [{full_path, type_atom} | acc])
  end
end
