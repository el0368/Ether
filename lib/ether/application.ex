defmodule Ether.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EtherWeb.Telemetry,
      # Ether.Repo,
      {DNSCluster, query: Application.get_env(:ether, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ether.PubSub},
      # Ether Agents - File Operations
      Ether.Agents.FileServerAgent,
      Ether.Agents.TestingAgent,
      Ether.Agents.LintAgent,
      Ether.Agents.FormatAgent,
      # Quality Assurance
      # Ether.Agents.QualityAgent,
      
      # Advanced Agents (Phase 4)
      # Ether.Agents.RefactorAgent,
      # Ether.Agents.GitAgent,
      # Ether.Agents.CommandAgent,

      # Phase 6: LSP
      Ether.Agents.LSPAgent,

      # Start to serve requests, typically the last entry
      EtherWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ether.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EtherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
