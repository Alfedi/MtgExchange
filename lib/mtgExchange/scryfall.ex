defmodule MtgExchange.Scryfall do
  use Tesla

  def client() do
    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://api.scryfall.com"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middlewares)
  end

  def fuzzy_search(name) do
    get(client(), "/cards/named", query: [fuzzy: name])
  end

  def search(name) do
    get(client(), "/cards/named", query: [exact: name])
  end

  def id_search(id) do
    get(client(), "/cards/" <> id)
  end

  def autocomplete(term) do
    get(client(), "/cards/autocomplete", query: [q: term])
  end
end
