defmodule MtgExchange.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :name, :string, null: false
      add :hashed_password, :string, null: false
      timestamps()
    end

    create unique_index(:users, [:name])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:cards, primary_key: false) do
      add :uuid, :string, primary_key: true
      add :quantity, :integer
      add :user, references(:users, name: "user", on_delete: :delete_all)
    end

    create table(:exchanges) do
      add :user1, references(:users, name: "user1", on_delete: :delete_all)
      add :user2, references(:users, name: "user2", on_delete: :delete_all)
      add :user1_list, {:array, :string}
      add :user2_list, {:array, :string}
      add :status, :string
      timestamps()
    end
  end
end
