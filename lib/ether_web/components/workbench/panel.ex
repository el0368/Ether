defmodule EtherWeb.Components.Workbench.Panel do
  @moduledoc """
  The Panel component - contains terminal, output, and debug console.
  Follows VS Code's panelPart.ts architecture pattern.
  """
  use Phoenix.Component

  attr :active_panel, :string, default: "terminal"

  def panel(assigns) do
    ~H"""
    <div class="h-[var(--vscode-panel-height)] border-t border-[#2b2b2b] bg-[var(--vscode-editor-background)] flex flex-col">
      <div class="h-[35px] flex items-center px-4 gap-4 text-[11px] font-bold uppercase border-b border-[#2b2b2b]">
        <span class={"cursor-pointer #{if @active_panel == "terminal", do: "text-white border-b border-white pb-1", else: "opacity-50"}"}>
          Terminal
        </span>
        <span class={"cursor-pointer #{if @active_panel == "output", do: "text-white border-b border-white pb-1", else: "opacity-50"}"}>
          Output
        </span>
        <span class={"cursor-pointer #{if @active_panel == "debug", do: "text-white border-b border-white pb-1", else: "opacity-50"}"}>
          Debug Console
        </span>
      </div>
      <div class="flex-1 bg-black overflow-hidden font-mono text-[13px] p-2 leading-tight">
        <%= case @active_panel do %>
          <% "terminal" -> %>
            <div class="text-green-500">ether@desktop:~/project$ _</div>
          <% "output" -> %>
            <div class="text-gray-400">No output yet.</div>
          <% "debug" -> %>
            <div class="text-gray-400">Debug console ready.</div>
          <% _ -> %>
            <div class="text-green-500">ether@desktop:~/project$ _</div>
        <% end %>
      </div>
    </div>
    """
  end
end
