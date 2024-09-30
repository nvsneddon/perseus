defmodule PerseusWeb.Resolvers.AuthTest do
  use Perseus.DataCase, async: true

  alias Perseus.Auth
  alias PerseusWeb.Resolvers

  import Perseus.AccountsFixtures

  describe "login_user/3" do
    setup do
      %{user: user_fixture()}
    end

    test "with valid context should login user", %{user: user} do
      result = Resolvers.Auth.login_user(nil, nil, %{context: %{email: user.email}})

      # Assert that the resolver returns :ok and a session_token
      assert {:ok, %{session_token: session_token}} = result
      assert {:ok, ^user} = Auth.find_user(session_token)
    end

    test "with invalid email address should return error" do
      result = Resolvers.Auth.login_user(nil, nil, %{context: %{email: "invalid@example.com"}})

      # Assert that the resolver returns :ok and a session_token
      assert {:error, "User not found"} = result
    end
  end

  describe "signup_user/3" do
    setup do
      %{user: valid_user_attributes()}
    end

    test "with valid data should signup user", %{user: user} do
      result = Resolvers.Auth.signup_user(nil, %{user: user}, %{context: %{email: user.email}})

      assert {:ok, %{session: _, new_user: created_user}} = result
      assert created_user.email == user.email
      assert created_user.first_name == user.first_name
      assert created_user.last_name == user.last_name
      assert created_user.verified == false
    end

    test "with invalid data should return a changeset" do
      result =
        Resolvers.Auth.signup_user(nil, %{user: %{first_name: "test"}}, %{
          context: %{email: "invalid"}
        })

      assert {:error, %Ecto.Changeset{} = changeset} = result
      assert "can't be blank" in errors_on(changeset).last_name
    end
  end
end
