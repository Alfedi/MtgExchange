defmodule MtgExchangeWeb.CardsListLive do
  use MtgExchangeWeb, :live_view

  def render(%{live_action: :me} = assigns) do
    ~H"""
    <div class="absolute">
      <.header class="text-center">
        Card Search
      </.header>
      <form phx-change="suggest">
        <input
          type="text"
          name="q"
          value={@query}
          list="matches"
          placeholder="Type card name..."
          {%{readonly: @loading}}
          autocomplete="off"
          class="mb-10"
        />
        <.button>Search Card</.button>
      </form>
      <!-- Carta resultado -->
      <%= if @result do %>
        <div class="flex flex-row">
          <.card_match match={@result} width="400px" class="mr-5 mb-5 rounded-3xl" />
          <div class="flex flex-col">
            <p>Quantity</p>
            <form phx-submit="add_card">
              <input
                type="number"
                name="quantity"
                placeholder="How many copies?"
                autocomplete="off"
                class="mb-1"
                value="1"
              />
              <.button>Add Card</.button>
            </form>
          </div>
        </div>
      <% else %>
        <!-- Lista de matches -->
        <div class="flex flex-row flex-wrap">
          <%= for m <- @matches do %>
            <.card_match
              match={m}
              class="border-4 border-transparent rounded-2xl hover:border-sky-600"
            />
          <% end %>
        </div>
      <% end %>
      <!-- Card List -->
      <hr />
      <.header class="text-center mb-5 mt-3">
        Your Cards
      </.header>
      <div class="flex flex-row flex-wrap">
        <%= for c <- @cards do %>
          <.card data={c} />
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{live_action: :others} = assigns) do
    ~H"""
    <div class="absolute">
      <.header class="text-center mb-5">
        <%= @name %>'s Cards
      </.header>
      <hr class="mb-5" />
      <div class="flex flex-row flex-wrap">
        <.card data={@cards} />
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    case socket.assigns.live_action == :me do
      true ->
        {:ok,
         assign(socket,
           query: nil,
           result: nil,
           loading: false,
           matches: [],
           cards: get_user_cards(socket.assigns.current_user.id)
         )}

      false ->
        {:ok, %{name: name}} = MtgExchange.Repo.get_user(params["id"])

        {:ok,
         assign(socket,
           query: nil,
           result: nil,
           loading: false,
           matches: [],
           cards: get_user_cards(params["id"]),
           name: name
         )}
    end
  end

  def handle_event("suggest", %{"q" => query}, socket)
      when byte_size(query) <= 100 do
    suggestions = MtgExchange.Scryfall.autocomplete(query)

    new_suggestions =
      Enum.map(suggestions, fn x ->
        {:ok, %{body: body}} = MtgExchange.Scryfall.search(x)
        body
      end)

    {:noreply, assign(socket, matches: new_suggestions)}
  end

  def handle_event("search", %{"q" => query}, socket)
      when byte_size(query) <= 100 do
    send(self(), {:search, query})

    {:noreply,
     assign(socket, query: query, result: %{id: "Searching..."}, loading: true, matches: [])}
  end

  def handle_event("add_card", %{"quantity" => quantity}, socket) do
    MtgExchange.Repo.insert_card(%MtgExchange.Models.Cards{
      uuid: socket.assigns.result["id"],
      quantity: quantity |> String.to_integer(),
      user: socket.assigns.current_user.id,
      scryfall_object: socket.assigns.result
    })

    {:noreply,
     socket
     |> put_flash(:info, "Card added succesfully")
     |> redirect(to: ~p"/cards")}
  end

  def handle_info({:search, query}, socket) do
    {:ok, %{body: card}} = MtgExchange.Scryfall.fuzzy_search(query)
    {:noreply, assign(socket, loading: false, result: card, matches: [])}
  end

  defp get_user_cards(user_id) do
    user_id |> MtgExchange.Repo.list_cards_from_user()
  end
end
