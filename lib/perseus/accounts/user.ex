defmodule Perseus.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :verified, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email])
    |> validate_format(:email, ~r/@*\.[A-Za-z.]{2,}/, message: "Must be a valid email address")
    |> unique_constraint(:email, name: :unique_email)
    |> validate_required([:first_name, :last_name, :email])
  end
end
