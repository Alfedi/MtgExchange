defmodule MtgExchange.Repo do
  use Ecto.Repo,
    otp_app: :mtgExchange,
    adapter: Ecto.Adapters.Postgres
end
