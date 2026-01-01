defmodule Aether.Desktop.MenuBar do
  @moduledoc """
  Defines the native menu bar for the Aether IDE main window.
  """
  use Desktop.Menu

  @impl Desktop.Menu
  def mount(socket) do
    {:ok, socket}
  end

  @impl Desktop.Menu
  def handle_event("quit", socket) do
    Desktop.Window.quit()
    {:noreply, socket}
  end

  @impl Desktop.Menu
  def handle_event(command, socket) do
    IO.puts("Menu command: #{command}")
    # In the future, we can broadcast these to the Phoenix channels 
    # or handle them directly properly
    {:noreply, socket}
  end

  @impl Desktop.Menu
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  @impl Desktop.Menu
  def render(assigns) do
    # Using raw string to avoid HEEX debug comments which break the XML parser
    """
    <menubar>
      <menu label="File">
        <item onclick="new_file">New</item>
        <item onclick="open_file">Open...</item>
        <item onclick="save_file">Save</item>
        <hr/>
        <item onclick="quit">Exit</item>
      </menu>
      
      <menu label="Edit">
        <item onclick="undo">Undo</item>
        <item onclick="redo">Redo</item>
        <hr/>
        <item onclick="cut">Cut</item>
        <item onclick="copy">Copy</item>
        <item onclick="paste">Paste</item>
      </menu>

      <menu label="View">
        <item onclick="toggle_terminal">Toggle Terminal</item>
        <item onclick="toggle_filetree">Toggle File Tree</item>
        <hr/>
        <item onclick="devtools">Developer Tools</item>
      </menu>

      <menu label="Help">
        <item onclick="docs">Documentation</item>
        <item onclick="about">About Aether</item>
      </menu>
    </menubar>
    """
  end
end
