defmodule Perseus.Auth.TokenStore do
  use GenServer

  @session_table :session_tokens
  @signup_table :signup_tokens
  @magic_link_table :magic_link_tokens

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    init_table(@session_table)
    init_table(@magic_link_table)
    init_table(@signup_table)
    {:ok, state}
  end

  defp init_table(table) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:set, :public, :named_table, read_concurrency: true])
    end
  end

  def store_magic_link_token(token, email, ttl) do
    store_token(@magic_link_table, token, email, ttl)
  end

  def store_signup_token(token, email, ttl) do
    store_token(@signup_table, token, email, ttl)
  end

  def store_session_token(token, profile, ttl) do
    store_token(@session_table, token, profile, ttl)
  end

  defp store_token(table, token, data, ttl, unit \\ :second) do
    expires_at = calculate_expiration(ttl, unit)
    :ets.insert(table, {token, data, expires_at})
  end

  def validate_magic_link_token(token) do
    validate_token(token, @magic_link_table, true)
  end

  def validate_signup_token(token) do
    validate_token(token, @signup_table)
  end

  def validate_session_token(token) do
    validate_token(token, @session_table)
  end

  defp validate_token(token, table, delete_after_success \\ false) do
    with [{^token, data, expires_at}] <- get_token(token, table),
         :ok <- validate_expiration(expires_at) do
      if delete_after_success do
        delete_token(token, table)
      end

      {:ok, data}
    else
      [] ->
        {:error, :not_found}

      :expired ->
        {:error, :expired_token}

      _ ->
        {:error, :invalid_data}
    end
  end

  defp get_token(token, table) do
    :ets.lookup(table, token)
  end

  defp delete_token(token, table) do
    :ets.delete(table, token)
  end

  defp validate_expiration(expires_at) do
    DateTime.utc_now()
    |> DateTime.compare(expires_at)
    |> case do
      :lt ->
        :ok

      _ ->
        :expired
    end
  end

  defp calculate_expiration(ttl, unit) do
    DateTime.utc_now()
    |> DateTime.add(ttl, unit)
  end
end
