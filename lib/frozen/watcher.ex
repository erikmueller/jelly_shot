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

  def handle_info({_pid, {:fs, :file_event}, {path, event}}, _) do
    new_state = cond do
      Enum.member?(event, :created) ->
        Logger.debug "Created #{path}"
        Frozen.Repo.anew()

      #  Atom sure does a lot of renaming (actual rename, delete, ...)
      Enum.member?(event, :renamed) ->
        Logger.debug "Renamed #{path}"
        Frozen.Repo.anew()

      Enum.member?(event, :modified) ->
        Logger.debug "Modified #{path}"
        path
        |> Frozen.Post.file_to_slug
        |> Frozen.Repo.update_by_slug

      Enum.member?(event, :removed) ->
        Logger.debug "removed #{path}"
        path
        |> Frozen.Post.file_to_slug
        |> Frozen.Repo.delete_by_slug
    end

    {:noreply, new_state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
