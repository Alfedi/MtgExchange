defmodule MtgExchange.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
    end

    create table(:cards, primary_key: false) do
      add :uuid, :string, primary_key: true
      add :quantity, :integer
      add :user, references(:users, name: "user", on_delete: :delete_all)
    end

    create table(:exchanges) do
      add :offer_user, references(:users, name: "offer_user", on_delete: :delete_all)
      add :receive_user, references(:users, name: "receive_user", on_delete: :delete_all)
      add :offer_list, {:array, :string}
      add :receive_list, {:array, :string}
      add :status, :string
    end
  end
end
