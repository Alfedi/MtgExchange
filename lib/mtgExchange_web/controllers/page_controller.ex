defmodule MtgExchangeWeb.PageController do
  use MtgExchangeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
