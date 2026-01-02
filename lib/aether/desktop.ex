defmodule Aether.Desktop do
  @moduledoc """
  Desktop application wrapper for Aether IDE.
  Wraps `Desktop.Window` to provide a native window with WebView.
  """
  
  def start_link(_opts \\ []) do
    # Start the Desktop.Window process
    # This provides a real WebView (Edge/WebKit) pointing to our URL
    Desktop.Window.start_link(
      app: :aether,
      id: :main_window,
      title: "Aether IDE",
      size: {1280, 800},
      url: "http://localhost:4000",
      menubar: nil,
      style: Desktop.Wx.wxNO_BORDER() | Desktop.Wx.wxRESIZE_BORDER() | Desktop.Wx.wxCLIP_CHILDREN(),
      # Ensure we can debug the webview
      debugging: true
    )
  end
end
