defmodule MtgExchangeWeb.ExchangesListLive do
  use MtgExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Ongoing Exchanges
      </.header>
      <.table id="ongoing_exchanges" rows={@ongoing_exchanges}>
        <:col :let={exchange} label="Exchange"><%= exchange.id %></:col>
        <:action :let={exchange}>
          <.button phx-click="view_exchange" phx-value-id={exchange.id}>View Exchange</.button>
        </:action>
      </.table>

      <.header class="text-center">
        You have to confirm this exchanges
      </.header>
      <.table id="waiting_exchanges" rows={@waiting_exchanges}>
        <:col :let={exchange} label="Exchange"><%= exchange.id %></:col>
        <:action :let={exchange}>
          <.button phx-click="view_exchange" phx-value-id={exchange.id}>View Exchange</.button>
        </:action>
      </.table>

      <.header class="text-center">
        Finished Exchanges
      </.header>
      <.table id="finished_exchanges" rows={@finished_exchanges}>
        <:col :let={exchange} label="Exchange"><%= exchange.id %></:col>
        <:action :let={exchange}>
          <%= if exchange.status == :cancelled do %>
            <p class="bg-red-700">Cancelled</p>
          <% else %>
            <p class="bg-green-700">Confirmed</p>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    ongoing_exchanges =
      MtgExchange.Repo.list_ongoing_exchanges_from_user(socket.assigns.current_user.id)

    waiting_exchanges =
      MtgExchange.Repo.list_waiting_exchanges_from_user(socket.assigns.current_user.id)

    finished_exchanges =
      MtgExchange.Repo.list_finished_exchanges_from_user(socket.assigns.current_user.id)

    {:ok,
     assign(socket,
       ongoing_exchanges: ongoing_exchanges,
       waiting_exchanges: waiting_exchanges,
       finished_exchanges: finished_exchanges
     )}
  end

  def handle_event("view_exchange", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end
end
