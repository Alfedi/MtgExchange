defmodule MtgExchange.Repo do
  alias MtgExchange.Models.Users
  import Ecto.Query

  use Ecto.Repo,
    otp_app: :mtgExchange,
    adapter: Ecto.Adapters.Postgres

  # User Operations
  # ---------------

  def insert_user(user) do
    case insert_or_update(user) do
      {:ok, _} = res ->
        res

      error ->
        error
    end
  end

  def get_user(id) do
    case get(Users, id) do
      nil -> {:error, "No such user"}
      user -> {:ok, user}
    end
  end

  def get_users_name() do
    from(u in Users, select: u.name) |> all
  end

  def delete_user(user) do
    case delete(user) do
      {:ok, _} = res -> res
      _ = res -> res
    end
  end

  # Card Operations
  # ---------------

  def insert_card(card) do
    case insert(card) do
      {:ok, _} = res -> res
      error -> error
    end
  end

  def get_card(uuid) do
    case get(Cards, uuid) do
      nil -> {:error, "No such card"}
      card -> {:ok, card}
    end
  end

  def delete_card(card) do
    case delete(card) do
      {:ok, _} = res -> res
      error -> error
    end
  end

  # Exchange Operations
  # -------------------

  def insert_exchange(exchange) do
    case insert(exchange) do
      {:ok, _} = res -> res
      error -> error
    end
  end

  def get_exchange(id) do
    case get(Exchanges, id) do
      nil -> {:error, "No such exchange"}
      exchange -> exchange
    end
  end

  def delete_exchange(exchange) do
    case delete(exchange) do
      {:ok, _} = res -> res
      error -> error
    end
  end
end
