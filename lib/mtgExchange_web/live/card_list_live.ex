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
          class="mb-20"
        />
        <.button>Search Card</.button>
      </form>
      <!-- Carta resultado -->
      <%= if @result do %>
        <div class="flex flex-row">
          <%= if ! @result["image_uris"] and @result["card_faces"] do %>
            <img
              src={Enum.at(@result.scryfall_object["card_faces"], 0)["image_uris"]["large"]}
              class="m-1"
              alt={@result["name"]}
              style="width:336px;height:468px;"
            />
          <% else %>
            <img
              src={@result["image_uris"]["large"]}
              class="m-1"
              alt={@result["name"]}
              style="width:336px;height:468px;"
            />
          <% end %>
          <div class="flex flex-col">
            <p>Quantity</p>
            <form phx-submit="add_card">
              <input
                type="number"
                name="quantity"
                placeholder="How many copies?"
                autocomplete="off"
                class="mb-1"
              />
              <.button>Add Card</.button>
            </form>
          </div>
        </div>
      <% else %>
        <!-- Lista de matches -->
        <div class="flex flex-row flex-wrap">
          <%= for match <- @matches do %>
            <.link phx-click="search" phx-value-q={match["name"]}>
              <%= if ! match["image_uris"] and match["card_faces"] do %>
                <img
                  src={Enum.at(match["card_faces"], 0)["image_uris"]["normal"]}
                  class="m-1"
                  style="width:251px;height:350px;"
                  alt={match["name"]}
                />
              <% else %>
                <img
                  src={match["image_uris"]["normal"]}
                  class="m-1"
                  style="width:251px;height:350px;"
                  alt={match["name"]}
                />
              <% end %>
            </.link>
          <% end %>
        </div>
      <% end %>
      <!-- Card List -->
      <hr />
      <.header class="text-center">
        Your Cards
      </.header>
      <div class="flex flex-row flex-wrap">
        <%= for c <- @cards do %>
          <%= if ! c.scryfall_object["image_uris"] and c.scryfall_object["card_faces"] do %>
            <div class="relative">
              <.link href={c.scryfall_object["scryfall_uri"]} target="_blank">
                <img
                  src={Enum.at(c.scryfall_object["card_faces"], 0)["image_uris"]["normal"]}
                  class="m-1"
                  style="width:251px;height:350px;"
                  alt={c.scryfall_object["name"]}
                />
                <div class="absolute bg-black opacity-0 top-0 bottom-0 left-0 right-0 rounded-lg mt-2 ml-2 h-[calc(100%-13px)] w-[calc(100%-13px)] hover:opacity-70">
                  <div class="absolute text-white mt-10 text-center text-2xl">
                    <%= c.scryfall_object["name"] %><br /> X <%= c.quantity %>
                  </div>
                </div>
              </.link>
            </div>
          <% else %>
            <div class="relative">
              <.link href={c.scryfall_object["scryfall_uri"]} target="_blank">
                <img
                  src={c.scryfall_object["image_uris"]["normal"]}
                  class="m-1"
                  style="width:251px;height:350px;"
                  alt={c.scryfall_object["name"]}
                />
                <div class="absolute bg-black opacity-0 top-0 bottom-0 left-0 right-0 rounded-lg mt-2 ml-2 h-[calc(100%-13px)] w-[calc(100%-13px)] hover:opacity-70">
                  <div class="absolute text-white mt-10 text-center text-2xl">
                    <%= c.scryfall_object["name"] %><br /> X <%= c.quantity %>
                  </div>
                </div>
              </.link>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{live_action: :others} = assigns) do
    ~H"""
    <div>
      <.header class="text-center">
        <%= @name %>'s Cards
      </.header>
      <%= for c <- @cards do %>
        <%= if ! c.scryfall_object["image_uris"] and c.scryfall_object["card_faces"] do %>
          <.link href={c.scryfall_object["scryfall_uri"]} target="_blank">
            <img
              src={Enum.at(c.scryfall_object["card_faces"], 0)["image_uris"]["normal"]}
              class="m-1"
              style="width:251px;height:350px;"
              alt={c.scryfall_object["name"]}
            />
          </.link>
        <% else %>
          <.link href={c.scryfall_object["scryfall_uri"]} target="_blank">
            <img
              src={c.scryfall_object["image_uris"]["normal"]}
              class="m-1"
              style="width:251px;height:350px;"
              alt={c.scryfall_object["name"]}
            />
          </.link>
        <% end %>
      <% end %>
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
    {:ok, %{body: %{"data" => suggestions}}} = MtgExchange.Scryfall.autocomplete(query)

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
    IO.inspect(socket)

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
