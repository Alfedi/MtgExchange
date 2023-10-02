defmodule MtgExchangeWeb.ExchangeLive do
  use MtgExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Exchange
      </.header>
      <%= if @status == :cancelled do %>
        <.header class="text-center text-slate-100 bg-red-700">
          Cancelled Exchange
        </.header>
      <% end %>
      <%= if @status == :done do %>
        <.header class="text-center bg-green-700">
          Exchange Finished
        </.header>
      <% end %>
      <div class="flex items-stretch gap-x-5 inset-0">
        <div class="py-10">
          <.header class="text-center">
            Your Cards
          </.header>
          <.table id="user1_list" rows={@user1_list}>
            <:col :let={card} label="Card Name">
              <%= card.uuid %>
            </:col>
            <:action :let={card}>
              <%= if @status != :cancelled and @status != :done do %>
                <.button phx-click="add_card" phx-value-user1-card={card.uuid} phx-value-id={@id}>
                  Add Card
                </.button>
              <% end %>
            </:action>
          </.table>
        </div>
        <div class="py-10 grid-cols-1">
          <div>
            <%= if @user1_offer != nil do %>
              <.table id="user1_offer" rows={@user1_offer}>
                <:col :let={ncard} label="Your Offer">
                  <%= ncard %>
                </:col>
                <:action :let={card}>
                  <%= if @status != :cancelled and @status != :done do %>
                    <.button phx-click="remove_card" phx-value-user1-card={card} phx-value-id={@id}>
                      Remove Card
                    </.button>
                  <% end %>
                </:action>
              </.table>
            <% else %>
              <.table id="user1_offer" rows={[]}>
                <:col :let={ncard} label="Your Offer">
                  <%= ncard.uuid %>
                </:col>
              </.table>
            <% end %>
          </div>
          <div>
            <%= if @user2_offer != nil do %>
              <.table id="user1_offer" rows={@user2_offer}>
                <:col :let={ncard} label="Their Offer">
                  <%= ncard %>
                </:col>
                <:action :let={card}>
                  <%= if @status != :cancelled and @status != :done do %>
                    <.button phx-click="remove_card" phx-value-user2-card={card} phx-value-id={@id}>
                      Remove Card
                    </.button>
                  <% end %>
                </:action>
              </.table>
            <% else %>
              <.table id="user2_offer" rows={[]}>
                <:col :let={ncard} label="Their Offer">
                  <%= ncard %>
                </:col>
              </.table>
            <% end %>
          </div>
        </div>
        <div class="py-10 right-10">
          <.header class="text-center">
            Their Cards
          </.header>
          <.table id="user2_list" rows={@user2_list}>
            <:col :let={card} label="Card Name">
              <%= card.uuid %>
            </:col>
            <:action :let={card}>
              <%= if @status != :cancelled and @status != :done do %>
                <.button phx-click="add_card" phx-value-user2-card={card.uuid} phx-value-id={@id}>
                  Add Card
                </.button>
              <% end %>
            </:action>
          </.table>
        </div>
      </div>
      <%= if @status != :cancelled and @status != :done do %>
        <.button phx-click="cancel" phx-value-id={@id}>Cancel Exchange</.button>
        <%= if (@current_user.id == @user1 and @status == :wait_confirm_user1) or (@current_user.id == @user2 and @status != :wait_confirm_user_2) or (@status == :ongoing) do %>
          <.button phx-click="confirm" phx-value-id={@id}>Confirm Exchange</.button>
        <% else %>
          <p>Waiting for Confirmation...</p>
        <% end %>
      <% end %>
    </div>
    """
  end

  def mount(params, _session, socket) do
    %{
      user1: user1_id,
      user2: user2_id,
      user1_list: user1_offer,
      user2_list: user2_offer,
      status: status
    } =
      MtgExchange.Repo.get_exchange(params["id"])

    user1_list = MtgExchange.Repo.list_cards_from_user(socket.assigns.current_user.id)

    if user2_id == socket.assigns.current_user.id do
      user2_list = MtgExchange.Repo.list_cards_from_user(user1_id)

      {:ok,
       assign(socket,
         id: params["id"],
         user1: user1_id,
         user2: user2_id,
         user1_list: user1_list,
         user2_list: user2_list,
         user1_offer: user2_offer,
         user2_offer: user1_offer,
         status: status
       )}
    else
      user2_list = MtgExchange.Repo.list_cards_from_user(user2_id)

      {:ok,
       assign(socket,
         id: params["id"],
         user1: user1_id,
         user2: user2_id,
         user1_list: user1_list,
         user2_list: user2_list,
         user1_offer: user1_offer,
         user2_offer: user2_offer,
         status: status
       )}
    end
  end

  def handle_event("add_card", %{"user1-card" => user1_card, "id" => id}, socket) do
    exchange =
      MtgExchange.Repo.get_exchange(id)

    if exchange.user1_list == nil do
      Ecto.Changeset.change(exchange, user1_list: [user1_card])
      |> MtgExchange.Repo.update_exchange()
    else
      Ecto.Changeset.change(exchange, user1_list: [user1_card | exchange.user1_list])
      |> MtgExchange.Repo.update_exchange()
    end

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end

  def handle_event("add_card", %{"user2-card" => user2_card, "id" => id}, socket) do
    exchange =
      MtgExchange.Repo.get_exchange(id)

    if exchange.user2_list == nil do
      Ecto.Changeset.change(exchange, user2_list: [user2_card])
      |> MtgExchange.Repo.update_exchange()
    else
      Ecto.Changeset.change(exchange, user2_list: [user2_card | exchange.user2_list])
      |> MtgExchange.Repo.update_exchange()
    end

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end

  def handle_event("remove_card", %{"user1-card" => user1_card, "id" => id}, socket) do
    exchange = MtgExchange.Repo.get_exchange(id)
    new_list = List.delete(exchange.user1_list, user1_card)

    Ecto.Changeset.change(exchange, user1_list: new_list)
    |> MtgExchange.Repo.update_exchange()

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end

  def handle_event("remove_card", %{"user2-card" => user2_card, "id" => id}, socket) do
    exchange = MtgExchange.Repo.get_exchange(id)
    new_list = List.delete(exchange.user2_list, user2_card)

    Ecto.Changeset.change(exchange, user2_list: new_list)
    |> MtgExchange.Repo.update_exchange()

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end

  def handle_event("cancel", %{"id" => id}, socket) do
    id
    |> MtgExchange.Repo.get_exchange()
    |> Ecto.Changeset.change(status: :cancelled)
    |> MtgExchange.Repo.update_exchange()

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end

  def handle_event("confirm", %{"id" => id}, socket) do
    IO.inspect(socket)
    exchange = MtgExchange.Repo.get_exchange(id)

    case exchange.status do
      :ongoing ->
        if socket.assigns.current_user.id == exchange.user2 do
          Ecto.Changeset.change(exchange, status: :wait_confirm_user1)
          |> MtgExchange.Repo.update_exchange()
        else
          Ecto.Changeset.change(exchange, status: :wait_confirm_user2)
          |> MtgExchange.Repo.update_exchange()
        end

      :wait_confirm_user2 ->
        Ecto.Changeset.change(exchange, status: :done)
        |> MtgExchange.Repo.update_exchange()

      :wait_confirm_user1 ->
        Ecto.Changeset.change(exchange, status: :done)
        |> MtgExchange.Repo.update_exchange()
    end

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end
end
