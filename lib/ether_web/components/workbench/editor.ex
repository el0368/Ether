defmodule EtherWeb.Components.Workbench.Editor do
  @moduledoc """
  The Editor component - contains Monaco editor integration.
  Follows VS Code's editor Part architecture pattern.
  """
  use Phoenix.Component

  attr :active_file, :map, default: nil

  def editor(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col min-w-0 bg-[var(--vscode-editor-background)]">
      <div class="flex-1 relative">
        <div
          id="monaco-editor-container"
          class="h-full w-full"
          phx-hook="MonacoEditor"
          phx-update="ignore"
          data-path={if @active_file, do: @active_file.path, else: ""}
        >
          <%= if !@active_file do %>
            <.welcome_page />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp welcome_page(assigns) do
    ~H"""
    <div class="h-full flex flex-col items-center justify-center gap-8 opacity-40 select-none">
      <img src="/images/logo.png" class="w-32 h-32" />
      <div class="flex flex-col items-center gap-2 text-[var(--vscode-editor-foreground)] text-sm italic font-light tracking-widest">
        <span>ctrl + p to search files</span>
        <span>ctrl + shift + f to search text</span>
        <span>ctrl + \ to split editor</span>
      </div>
    </div>
    """
  end
end
