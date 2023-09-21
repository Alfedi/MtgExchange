defmodule MtgExchangeWeb.UserController do
  use MtgExchangeWeb, :controller
  alias MtgExchange.Repo

  def users(conn, _params) do
    u = Repo.get_users_name()
    render(conn, :users, users: u)
  end

  def register(conn, _params) do
    render(conn, :register)
  end

  def new_user(conn, params) do
    %MtgExchange.Models.Users{name: params[:name]}
    |> MtgExchange.Models.Users.changeset(params)
    |> MtgExchange.Repo.insert_user()

    render(conn, :home)
  end
end
