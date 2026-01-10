defmodule Ether.Native.Scanner do
  @on_load :load_nif

  def load_nif do
    path = :code.priv_dir(:ether) ++ ~c"/native/scanner_nif"
    :erlang.load_nif(path, 0)
  end

  def scan_yield_nif(_resource, _path, _pid, _depth), do: :erlang.nif_error(:nif_not_loaded)
end
