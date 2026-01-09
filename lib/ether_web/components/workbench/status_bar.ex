defmodule EtherWeb.Components.Workbench.StatusBar do
  @moduledoc """
  The StatusBar component - displays connection status, encoding, and other info.
  Follows VS Code's statusbarPart.ts architecture pattern.
  """
  use Phoenix.Component
  import EtherWeb.CoreComponents

  attr :active_file, :map, default: nil

  def status_bar(assigns) do
    ~H"""
    <div class="h-[var(--vscode-statusbar-height)] min-h-[var(--vscode-statusbar-height)] bg-[var(--vscode-statusbar-background)] flex items-center justify-between px-3 text-[12px] text-[var(--vscode-statusbar-foreground)]">
      <div class="flex items-center gap-3">
        <div class="flex items-center gap-1 hover:bg-[#ffffff22] px-1 cursor-pointer">
          <.icon name="lucide-signal" class="w-3 h-3" />
          <span>Connected</span>
        </div>
      </div>
      <div class="flex items-center gap-4">
        <div class="hover:bg-[#ffffff22] px-1 cursor-pointer">UTF-8</div>
        <div class="hover:bg-[#ffffff22] px-1 cursor-pointer">Spaces: 2</div>
        <div class="hover:bg-[#ffffff22] px-1 cursor-pointer">
          <%= if @active_file, do: get_language(@active_file.path), else: "LiveView" %>
        </div>
      </div>
    </div>
    """
  end

  defp get_language(path) when is_binary(path) do
    case Path.extname(path) do
      ext when ext in [".ex", ".exs"] -> "Elixir"
      ".heex" -> "HEEx"
      ".js" -> "JavaScript"
      ".ts" -> "TypeScript"
      ".css" -> "CSS"
      ".json" -> "JSON"
      ".md" -> "Markdown"
      ".zig" -> "Zig"
      _ -> "Plain Text"
    end
  end

  defp get_language(_), do: "LiveView"
end
