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
          <div class="px-2 py-1 hover:bg-[#505050] rounded cursor-pointer">File</div>
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
      <div data-tauri-no-drag phx-update="ignore" class="flex items-center h-full text-[13px]" phx-hook="WindowControls" id="window-controls">
        <div data-window-action="minimize" class="flex items-center justify-center w-[46px] h-full hover:bg-[#ffffff1a] cursor-pointer" title="Minimize">
          <svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 5h10" stroke="currentColor" stroke-width="1"/>
          </svg>
        </div>
        <div data-window-action="maximize" class="flex items-center justify-center w-[46px] h-full hover:bg-[#ffffff1a] cursor-pointer" title="Maximize">
          <%!-- Maximize Icon --%>
          <svg class="maximize-icon" width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M1 1h8v8H1V1zm1 1v6h6V2H2z" fill="currentColor"/>
          </svg>
          <%!-- Restore Icon --%>
          <svg class="restore-icon hidden" width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M3 3v7h7V3H3zm1 6V4h5v5H4z" fill="currentColor"/>
            <path d="M1 7V1h6v1H2v5H1z" fill="currentColor"/>
          </svg>
        </div>
        <div data-window-action="close" class="flex items-center justify-center w-[46px] h-full hover:bg-[#e81123] cursor-pointer group" title="Close">
          <svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 0L10 10M10 0L0 10" stroke="currentColor" stroke-width="1" class="group-hover:stroke-white"/>
          </svg>
        </div>
      </div>
    </div>
    """
  end
end
