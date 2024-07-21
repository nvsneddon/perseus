defmodule Perseus.Repo do
  use Ecto.Repo,
    otp_app: :perseus,
    adapter: Ecto.Adapters.Postgres
end
