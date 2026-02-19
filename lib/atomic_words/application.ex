defmodule AtomicWords.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AtomicWordsWeb.Telemetry,
      AtomicWords.Repo,
      {DNSCluster, query: Application.get_env(:atomic_words, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AtomicWords.PubSub},
      # Start a worker by calling: AtomicWords.Worker.start_link(arg)
      # {AtomicWords.Worker, arg},
      # Start to serve requests, typically the last entry
      AtomicWordsWeb.Endpoint,
      {Goth, name: AtomicWords},
      {Finch, name: AtomicWords.Finch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AtomicWords.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AtomicWordsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
