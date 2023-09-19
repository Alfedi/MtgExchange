defmodule MtgExchange.Models.Cards do
  use Ecto.Schema

  schema "cards" do
    field :uuid, :string, primary_key: true
    field :quantity, :integer
    field :user, :integer
  end
end

defmodule MtgExchange.Models.Users do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    has_many :cards, MtgExchange.Models.Cards, foreign_key: :user

    timestamps()
  end
end

defmodule MtgExchange.Models.Exchanges do
  use Ecto.Schema

  schema "exchanges" do
    field :offer_user, :integer
    field :receive_user, :integer

    has_many :offer_list, MtgExchange.Models.Cards,
      foreign_key: :uuid,
      where: [user: :offer_user]

    has_many :receive_list, MtgExchange.Models.Cards,
      foreign_key: :uuid,
      where: [user: :receive_user]

    field :done, :boolean, default: false

    timestamps()
  end
end
