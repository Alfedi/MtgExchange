defmodule MtgExchange.Scryfall do
  use Tesla

  def client() do
    middlewares = [
      Tesla.Middleware.BaseUrl,
      "https://api.scryfall.com",
      Tesla.Middleware.JSON
    ]

    Tesla.client(middlewares)
  end

  def cardById(client, name) do
    Tesla.get(client, )
  end
end
