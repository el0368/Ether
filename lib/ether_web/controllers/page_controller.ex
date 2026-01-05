defmodule EtherWeb.PageController do
  use EtherWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
