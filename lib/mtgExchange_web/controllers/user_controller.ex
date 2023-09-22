defmodule MtgExchangeWeb.UserController do
  use MtgExchangeWeb, :controller
  alias MtgExchange.Repo

  def users(conn, _params) do
    u = Repo.get_users_name()
    render(conn, :users, users: u)
  end
end
