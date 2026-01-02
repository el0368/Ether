defmodule Aether.Desktop do
  @moduledoc """
  Desktop application wrapper for Aether IDE.
  Wraps `Desktop.Window` to provide a native window with WebView.
  """
  
  def start_link(_opts \\ []) do
    # Start the Desktop.Window process
    # For now we are just starting the window
    {:ok, pid} =
      Desktop.Window.start_link(
        app: :aether,
        id: :main_window,
        title: "Ether IDE",
        size: {1280, 800},
        url: "http://localhost:4000",
        menubar: nil,
        debugging: true
      )

    # Register the main window process so we can find it from channels
    # Process.register(pid, :main_window) -- Already registered by id: :main_window
    {:ok, pid}
  end
end
