defmodule Perseus.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :verified, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
