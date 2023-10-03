defmodule MtgExchange.Repo do
  alias MtgExchange.Models.Cards
  alias MtgExchange.Models.Exchanges
  alias MtgExchange.Account.User
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
    case MtgExchange.Repo.get(User, id) do
      nil -> {:error, "No such user"}
      user -> {:ok, user}
    end
  end

  def get_users() do
    from(u in User) |> all
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
    case MtgExchange.Repo.insert(card) do
      {:ok, _} = res -> res
      error -> error
    end
  end

  def get_card_by_uuid(uuid) do
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

  def list_cards_from_user(user_id) do
    query =
      from c in Cards,
        where: c.user == ^user_id

    query |> all
  end

  # Exchange Operations
  # -------------------

  def insert_exchange(exchange) do
    case insert(exchange) do
      {:ok, _} = res -> res
      error -> error
    end
  end

  def list_ongoing_exchanges_from_user(user_id) do
    query =
      from e in Exchanges,
        where:
          (e.user1 == ^user_id and e.status == :wait_confirm_user2) or
            (e.user2 == ^user_id and e.status == :wait_confirm_user1) or e.status == :ongoing

    query |> all
  end

  def list_waiting_exchanges_from_user(user_id) do
    query =
      from e in Exchanges,
        where:
          (e.user1 == ^user_id and e.status == :wait_confirm_user1) or
            (e.user2 == ^user_id and e.status == :wait_confirm_user2)

    query |> all
  end

  def list_finished_exchanges_from_user(user_id) do
    query =
      from e in Exchanges,
        where: e.status == :done or e.status == :cancelled,
        where: e.user1 == ^user_id or e.user2 == ^user_id,
        order_by: [desc: e.updated_at]

    query |> all
  end

  def get_exchange(id) do
    case get(Exchanges, id) do
      nil -> {:error, "No such exchange"}
      exchange -> exchange
    end
  end

  def update_exchange(exchange) do
    case update(exchange) do
      {:ok, _} = changeset -> changeset
      error -> error
    end
  end

  def delete_exchange(exchange) do
    case delete(exchange) do
      {:ok, _} = res -> res
      error -> error
    end
  end
end
