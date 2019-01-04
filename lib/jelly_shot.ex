@moduledoc """
This is the main JellyShot application.
"""

defmodule JellyShot do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    repos = Application.get_env(:jelly_shot, :repositories) || []

    children = [
      supervisor(JellyShot.Endpoint, []),
    ] ++ Enum.map(repos, &(worker(&1[:module], [&1[:source]])))

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JellyShot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    JellyShot.Endpoint.config_change(changed, removed)
    :ok
  end
end
