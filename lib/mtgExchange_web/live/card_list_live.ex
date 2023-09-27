defmodule MtgExchangeWeb.CardsListLive do
  use MtgExchangeWeb, :live_view

  def render(%{live_action: :me} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Card Search
      </.header>
      <form phx-change="suggest" phx-submit="search">
        <input
          type="text"
          name="q"
          value={@query}
          list="matches"
          placeholder="Search..."
          {%{readonly: @loading}}
        />
        <datalist id="matches">
          <%= for match <- @matches do %>
            <option value={match}><%= match %></option>
          <% end %>
        </datalist>
        <%= if @result do %>
          <pre><%= @result["name"] %></pre>
          <.button phx-click="add_card">Add Card</.button>
        <% end %>
      </form>

      <.header class="text-center">
        Card List
      </.header>
      <%= for c <- @cards do %>
        <%= c["name"] %><br />
      <% end %>
    </div>
    """
  end

  def render(%{live_action: :others} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Card List
      </.header>
      <%= for c <- @cards do %>
        <%= c["name"] %><br />
      <% end %>
    </div>
    """
  end

  def mount(params, _session, socket) do
    # Card list

    case socket.assigns.live_action == :me do
      true ->
        {:ok,
         assign(socket,
           query: nil,
           result: nil,
           loading: false,
           matches: [],
           cards: get_user_cards_name(socket.assigns.current_user.id)
         )}

      false ->
        {:ok,
         assign(socket,
           query: nil,
           result: nil,
           loading: false,
           matches: [],
           cards: get_user_cards_name(params["id"])
         )}
    end
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    {:ok, %{body: %{"data" => suggestions}}} = MtgExchange.Scryfall.autocomplete(query)
    {:noreply, assign(socket, matches: suggestions)}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    send(self(), {:search, query})

    {:noreply,
     assign(socket, query: query, result: %{id: "Searching..."}, loading: true, matches: [])}
  end

  def handle_event("add_card", _, socket) do
    MtgExchange.Repo.insert_card(%MtgExchange.Models.Cards{
      uuid: socket.assigns.result["id"],
      quantity: 1,
      user: socket.assigns.current_user.id
    })

    {:noreply,
     socket
     |> put_flash(:info, "Card added succesfully")
     |> redirect(to: ~p"/cards")}
  end

  def handle_info({:search, query}, socket) do
    # {result, _} = System.cmd("dict", ["#{query}"], stderr_to_stdout: true)
    {:ok, %{body: card}} = MtgExchange.Scryfall.fuzzy_search(query)
    {:noreply, assign(socket, loading: false, result: card, matches: [])}
  end

  defp get_user_cards_name(user_id) do
    {:ok, list} = MtgExchange.Repo.list_cards_from_user(user_id)

    Enum.map(list, fn x ->
      {:ok, %{body: body}} = MtgExchange.Scryfall.id_search(x)
      body
    end)
  end
end
