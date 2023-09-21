defmodule MtgExchange.Models.Cards do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :uuid, :string, primary_key: true
    field :quantity, :integer
    field :user, :integer
  end
end

defmodule MtgExchange.Models.Users do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    has_many :cards, MtgExchange.Models.Cards, foreign_key: :user

    timestamps()
  end

  def changeset(user, params) do
    user
    |> cast(params, [:name])
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

    field :status, Ecto.Enum, values: [:pending, :cancelled, :done]

    timestamps()
  end
end
