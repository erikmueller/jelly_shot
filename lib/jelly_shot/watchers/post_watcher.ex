require Logger

alias JellyShot.PostRepository, as: Repo

defmodule JellyShot.PostWatcher do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ignored)
  end

  def init(state) do
    path = Path.expand(Repo.get_source())

    {:ok, _pid} = :fs.start_link(:fs_watcher, path)
    :ok = :fs.subscribe(:fs_watcher)

    {:ok, state}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, events}}, state) do

    new_state = cond do
      :modified in events -> Repo.upsert_by_file_name(path)
      :removed in events -> Repo.delete_by_file_name(path)
      :created in events -> Repo.anew()
      :renamed in events -> Repo.anew()
      true -> state
    end

    {:noreply, new_state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
