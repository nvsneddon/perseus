defmodule Perseus.Accounts.TokenStore do
  use GenServer

  @session_table :session_tokens
  @magic_link_table :magic_link_tokens

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    init_table(@session_table)
    init_table(@magic_link_table)
    {:ok, state}
  end

  defp init_table(table) do
    if :ets.whereis(table) == :undefined do
      :ets.new(table, [:set, :public, :named_table, read_concurrency: true])
    end
  end

  @spec store_token(:magic_link | :session, binary(), binary(), integer()) :: true
  def store_token(:magic_link, token, email, ttl) do
    expires_at = DateTime.add(DateTime.utc_now(), ttl, :second)
    :ets.insert(@magic_link_table, {token, email, expires_at})
  end

  def store_token(:session, token, user_id, ttl) do
    expires_at = DateTime.add(DateTime.utc_now(), ttl, :second)
    :ets.insert(@session_table, {token, user_id, expires_at})
  end

  def validate_magic_link_token(token) do
    case validate_token(token, @magic_link_table) do
      {:ok, email} ->
        delete_token(token, :magic_link)
        {:ok, email}

      error ->
        error
    end
  end

  def validate_session_token(token) do
    validate_token(token, @session_table)
  end

  defp validate_token(token, table) do
    with [{^token, email, expires_at}] <- :ets.lookup(table, token),
         :ok <- validate_expiration(expires_at) do
      {:ok, email}
    else
      [] ->
        {:error, :not_found}

      :expired ->
        {:error, :expired_token}

      _ ->
        {:error, :invalid_data}
    end
  end

  def delete_token(token, :magic_link) do
    :ets.delete(@magic_link_table, token)
  end

  def delete_token(token, :session) do
    :ets.delete(@session_table, token)
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
end
