defmodule Perseus.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Perseus.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Perseus.Accounts.create_user()

    user
  end

  def valid_user_attributes(attr \\ %{}) do
    Enum.into(attr, %{
      email: unique_user_email(),
      first_name: "some first_name",
      last_name: "some last_name",
      verified: true
    })
  end
end
