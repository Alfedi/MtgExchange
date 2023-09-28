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
        <:action :let={user}><.link href={~p"/users/#{user.id}/cards"}>View Cards</.link></:action>
      </.table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    users = MtgExchange.Repo.get_users()
    {:ok, assign(socket, users: users)}
  end
end
