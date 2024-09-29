defmodule Perseus.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Perseus.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "someemail@example.com",
        first_name: "some first_name",
        last_name: "some last_name",
        verified: true
      })
      |> Perseus.Accounts.create_user()

    user
  end
end
