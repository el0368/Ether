defmodule EtherWeb.WorkbenchLiveTest do
  use EtherWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders the workbench shell", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    
    # Verify VS Code Layout Elements (via CSS variables/classes)
    assert html =~ "vscode-titleBar-height"
    assert html =~ "vscode-activityBar-width"
    assert html =~ "vscode-sidebar-width"
    assert html =~ "vscode-statusbar-height"
  end

  test "renders welcome page when no file is active", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    
    assert render(view) =~ "ctrl + p to search files"
    assert render(view) =~ "monaco-editor-container"
  end

  test "opens project folder on click", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    
    # Simulate clicking Open Folder
    view
    |> element("button", "Open Folder")
    |> render_click()

    # The scanner should be triggered (async)
    # We can check if the status bar or list updates if we had a mock scanner
    # For now, just verify it doesn't crash
  end
end
