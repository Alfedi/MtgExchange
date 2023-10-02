defmodule MtgExchangeWeb.UsersLive do
  use MtgExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        User List
      </.header>
      <.table id="users" rows={@users}>
        <:col :let={user} label="Name"><%= user.name %></:col>
        <:action :let={user}>
          <%= if user == @current_user do %>
            <.link href={~p"/cards"}>View Cards</.link>
          <% else %>
            <.link href={~p"/users/#{user.id}/cards"}>View Cards</.link>
          <% end %>
        </:action>
        <:action :let={user}>
          <%= if user != @current_user do %>
            <.button phx-click="new_exchange" phx-value-user-id={user.id}>
              Exchange
            </.button>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    users = MtgExchange.Repo.get_users()
    {:ok, assign(socket, users: users)}
  end

  def handle_event("new_exchange", %{"user-id" => id}, socket) do
    {:ok, %{id: id}} =
      MtgExchange.Repo.insert_exchange(%MtgExchange.Models.Exchanges{
        user1: socket.assigns.current_user.id,
        user2: id |> String.to_integer(),
        status: :ongoing
      })

    {:noreply, push_navigate(socket, to: ~p"/exchanges/#{id}")}
  end
end
