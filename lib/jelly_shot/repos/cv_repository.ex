require Logger

alias JellyShot.CV

defmodule JellyShot.CVRepository do
  def start_link(source) do
    use JellyShot.Watcher, [module: __MODULE__, source: source]
    file_name = Path.join([source, "cv.md"])

    Agent.start_link(fn ->
      {:ok, cv} = file_name |> Path.relative_to_cwd |> CV.transform

      cv
    end, name: __MODULE__)
  end

  def anew(source) do
    file_name = Path.join([source, "cv.md"])

    Agent.update(
      __MODULE__,
      transform_content(file_name)
    )
  end

  def get do
    Agent.get(__MODULE__, fn cv -> cv end)
  end

  def upsert_by_file_name(file_name) do
    Agent.update(__MODULE__, transform_content(file_name))
  end

  defp transform_content(file_name) do
    fn _  ->
      {:ok, cv} = file_name |> Path.relative_to_cwd |> CV.transform

      cv
    end
  end
end
