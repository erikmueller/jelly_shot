require Logger

alias JellyShot.Page

defmodule JellyShot.PageRepository do
  def start_link(source) do
    use JellyShot.Watcher, [module: __MODULE__, source: source]

    Agent.start_link(get_initial_state(source), name: __MODULE__)
  end

  def anew(source), do: Agent.update(__MODULE__, get_initial_state(source))


  def get_by_file_name(file_name) do
    Agent.get(__MODULE__, fn pages ->
      case pages[file_name] do
        nil -> :not_found
        page -> {:ok, page}
      end
    end)
  end

  def upsert_by_file_name(file_name) do
    Agent.update(__MODULE__, fn pages  ->
      {:ok, page} = file_name |> Path.relative_to_cwd |> Page.transform

      Map.merge(pages, page)
    end)
  end

  defp get_initial_state(source) do
    fn ->
      start = Timex.now()

      pages = source
        |> File.ls!
        |> Enum.map(&(Path.join([source, &1])))
        |> Flow.from_enumerable(max_demand: 1)
        |> Flow.filter(&(Path.extname(&1) == ".md"))
        |> Flow.map(&Page.transform/1)
        |> Flow.partition
        |> Enum.reduce(%{}, fn ({:ok, item}, acc) -> Map.merge(acc, item) end)

      Logger.debug fn -> "Compiled #{Enum.count(pages)} pages in #{Timex.diff Timex.now(), start, :milliseconds}ms." end

      pages
    end
  end
end
