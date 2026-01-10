defmodule EtherWeb.WorkbenchLive do
  use EtherWeb, :live_view
  import LiveSvelte

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Ether")
     |> assign(:active_sidebar, "files")}
  end

  def render(assigns) do
    ~H"""
    <.svelte name="Workbench" props={%{active_sidebar: @active_sidebar}} />
    """
  end

  def handle_event("set_sidebar", %{"panel" => panel}, socket) do
    {:noreply, assign(socket, :active_sidebar, panel)}
  end
end
