defmodule MtgExchangeWeb.CardsListLive do
  use MtgExchangeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Card List
      </.header>
      <%= for c <- @cards do %>
        <%= c["name"] %>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    cards = get_user_cards_name(socket.assigns.current_user)
    {:ok, assign(socket, cards: cards)}
  end

  defp get_user_cards_name(user) do
    {:ok, list} = MtgExchange.Repo.list_cards_from_user(user.id)

    Enum.map(list, fn x ->
      {:ok, %{body: body}} = MtgExchange.Scryfall.id_search(x)
      body
    end)
  end
end
