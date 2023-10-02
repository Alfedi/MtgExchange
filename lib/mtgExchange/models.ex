defmodule MtgExchange.Models.Cards do
  use Ecto.Schema

  @primary_key false

  schema "cards" do
    field :uuid, :string, primary_key: true
    field :quantity, :integer
    field :user, :integer
  end
end

defmodule MtgExchange.Models.Exchanges do
  use Ecto.Schema

  schema "exchanges" do
    field :user1, :integer
    field :user2, :integer
    field :user1_list, {:array, :string}
    field :user2_list, {:array, :string}

    field :status, Ecto.Enum,
      values: [:ongoing, :cancelled, :wait_confirm_user1, :wait_confirm_user2, :done]

    timestamps()
  end
end
