require Logger

defmodule Frozen.Watcher do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ignored)
  end

  def init(state) do
    path = Path.expand("priv/posts")

    :fs.start_link(:fs_watcher, path)
    :fs.subscribe(:fs_watcher)

    {:ok, state}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, [:inodemetamod]}}, _) do
    {:noreply, :ignored}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, event}}, state) do
    # We get an array of several events but we are only interested if there
    # was any modification
    if Enum.member?(event, :modified) do
      path
        |> Frozen.Post.file_to_slug
        |> Frozen.Repo.update_by_slug
    # in any other case we need to recompile the whole list since `:rename` could be
    # triggered by a lot of changes (rename, delete, ...)
    else
      Frozen.Repo.init()
    end

    {:noreply, state}
  end
end
