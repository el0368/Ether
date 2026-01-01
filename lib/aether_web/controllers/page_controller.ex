defmodule AetherWeb.PageController do
  use AetherWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
