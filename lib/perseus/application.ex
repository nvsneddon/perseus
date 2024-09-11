defmodule Perseus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PerseusWeb.Telemetry,
      Perseus.Repo,
      Perseus.Accounts.TokenStore,
      {DNSCluster, query: Application.get_env(:perseus, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Perseus.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Perseus.Finch},
      # Start a worker by calling: Perseus.Worker.start_link(arg)
      # {Perseus.Worker, arg},
      # Start to serve requests, typically the last entry
      PerseusWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Perseus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PerseusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
