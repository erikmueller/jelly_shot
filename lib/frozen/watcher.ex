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

  def handle_info({_pid, {:fs, :file_event}, {path, _event}}, _) do
    path
      |> Frozen.Post.file_to_slug
      |> Frozen.Repo.update_by_slug

    {:noreply, :ignored}
  end
end
