alias Frozen.Post

defmodule Frozen.Crawler do
  def ls() do
    start = Timex.now()

    posts = File.ls!("priv/posts")
      |> Enum.filter(&(Path.extname(&1) == ".md"))
      |> Enum.map(&compile_async/1)
      |> Enum.map(&Task.await/1)
      |> Enum.sort(&sort/2)

      IO.puts "Compiled #{Enum.count(posts)} posts in #{Timex.diff Timex.now(), start, :milliseconds}ms."

      posts
  end

  defp compile_async(file), do: Task.async(fn -> Post.compile file end)

  defp sort(a, b) do
    date_a = a.date
    date_b = b.date

    if (Timex.is_valid? date_a && Timex.is_valid? date_b), do: Timex.compare(date_a, date_b) > 0
  end
end
