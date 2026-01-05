defmodule EtherWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "editor:*", EtherWeb.EditorChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    IO.puts("UserSocket: CONNECTED")
    {:ok, socket}
  end

  @impl true
  def id(_socket) do
    IO.puts("UserSocket: ID CHECK")
    nil
  end
end
