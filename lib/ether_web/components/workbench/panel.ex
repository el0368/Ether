defmodule EtherWeb.Components.Workbench.Panel do
  @moduledoc """
  The Panel component - contains terminal, output, and debug console.
  Follows VS Code's panelPart.ts architecture pattern.
  """
  use Phoenix.Component

  attr :active_panel, :string, default: "terminal"

  def panel(assigns) do
    ~H"""
    <div class="h-[var(--vscode-panel-height)] border-t border-[#2b2b2b] bg-[var(--vscode-editor-background)] flex flex-col" x-data="{ activeTab: 'terminal' }">
      <div class="h-[35px] flex items-center px-4 gap-4 text-[11px] font-bold uppercase border-b border-[#2b2b2b]">
        <span 
          class="cursor-pointer border-b pb-1 border-transparent opacity-50 hover:opacity-100"
          x-bind:class="activeTab === 'terminal' && '!text-white !border-white !opacity-100'"
          x-on:click="activeTab = 'terminal'"
        >
          Terminal
        </span>
        <span 
          class="cursor-pointer border-b pb-1 border-transparent opacity-50 hover:opacity-100"
          x-bind:class="activeTab === 'output' && '!text-white !border-white !opacity-100'"
          x-on:click="activeTab = 'output'"
        >
          Output
        </span>
        <span 
          class="cursor-pointer border-b pb-1 border-transparent opacity-50 hover:opacity-100"
          x-bind:class="activeTab === 'debug' && '!text-white !border-white !opacity-100'"
          x-on:click="activeTab = 'debug'"
        >
          Debug Console
        </span>
      </div>
      <div class="flex-1 bg-black overflow-hidden font-mono text-[13px] p-2 leading-tight">
        <div x-show="activeTab === 'terminal'" class="h-full">
          <div class="text-green-500">ether@desktop:~/project$ _</div>
        </div>
        <div x-show="activeTab === 'output'" class="h-full" style="display: none;">
          <div class="text-gray-400">No output yet.</div>
        </div>
        <div x-show="activeTab === 'debug'" class="h-full" style="display: none;">
          <div class="text-gray-400">Debug console ready.</div>
        </div>
      </div>
    </div>
    """
  end
end
