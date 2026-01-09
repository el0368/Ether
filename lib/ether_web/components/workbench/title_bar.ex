defmodule EtherWeb.Components.Workbench.TitleBar do
  @moduledoc """
  The TitleBar component - contains logo, menu, file name, and window controls.
  Follows VS Code's titlebarPart.ts architecture pattern.
  """
  use Phoenix.Component

  attr :active_file, :map, default: nil

  def title_bar(assigns) do
    ~H"""
    <div data-tauri-drag-region class="h-[var(--vscode-titlebar-height)] min-h-[var(--vscode-titlebar-height)] bg-[var(--vscode-titlebar-activebackground)] flex items-center justify-between px-2 select-none border-b border-[#2b2b2b]">
      <div class="flex items-center gap-4 h-full">
        <div class="flex items-center gap-2">
          <img src="/images/logo.png" class="w-5 h-5" />
        </div>
        <div data-tauri-no-drag class="flex items-center gap-1 h-full text-[13px]">
          <div phx-click="toggle_sidebar" class="px-2 py-1 hover:bg-[#505050] rounded cursor-pointer">File</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">Edit</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">Selection</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">View</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">Go</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">Run</div>
          <div phx-click="toggle_panel" class="px-2 py-1 hover:bg-[#505050] rounded cursor-pointer">Terminal</div>
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-default opacity-50">Help</div>
        </div>
      </div>
      <div class="absolute left-1/2 -translate-x-1/2 text-[12px] opacity-60 font-medium">
        <%= if @active_file, do: @active_file.name, else: "Ether" %>
      </div>
      <div data-tauri-no-drag class="flex items-center gap-2 pr-2" phx-hook="WindowControls" id="window-controls">
        <div data-window-action="close" class="w-3 h-3 rounded-full bg-[#ff5f57] cursor-pointer hover:brightness-110"></div>
        <div data-window-action="minimize" class="w-3 h-3 rounded-full bg-[#febc2e] cursor-pointer hover:brightness-110"></div>
        <div data-window-action="maximize" class="w-3 h-3 rounded-full bg-[#28c840] cursor-pointer hover:brightness-110"></div>
      </div>
    </div>
    """
  end
end
