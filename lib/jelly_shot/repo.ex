require Logger

alias JellyShot.Post

defmodule JellyShot.Repo do
  def start_link do
    Agent.start_link(&get_initial_state/0, name: __MODULE__)
  end

  def anew, do: Agent.update(__MODULE__, fn _ -> get_initial_state() end)

  def list do
    Agent.get(__MODULE__, fn posts -> {:ok, posts} end)
  end

  def get_by_slug(slug) do
    Agent.get(__MODULE__, fn posts ->
      case Enum.find(posts, &(&1.slug == slug)) do
        nil -> :not_found
        post -> {:ok, post}
      end
    end)
  end

  def get_by_category(category) do
    Agent.get(__MODULE__, fn posts ->
      {:ok, Enum.filter(posts, &(Enum.member?(&1.categories, category)))}
    end)
  end

  def get_by_author(author) do
    Agent.get(__MODULE__, fn posts ->
      {:ok, Enum.filter(posts, &(Enum.member?(&1.authors, author)))}
    end)
  end

  def upsert_by_slug(slug) do
    start = Timex.now()
    file_name = "#{slug}.md"

    case Post.compile(file_name) do
      {:ok, new_post} ->
        Agent.update(__MODULE__, fn posts ->
          Logger.info "Updated #{file_name} in #{Timex.diff Timex.now(), start, :milliseconds}ms."

          case Enum.find_index(posts, &(&1.slug == slug)) do
            nil -> List.insert_at(posts, 0, new_post) |> Enum.sort(&sort/2)
            idx -> List.replace_at(posts, idx, new_post)
          end
        end)
      {:error, _} -> :ignored
    end
  end

  def delete_by_slug(slug) do
    Agent.update(__MODULE__, fn posts ->
      case Enum.find_index(posts, &(&1.slug == slug)) do
        nil -> posts
        idx -> List.delete_at(posts, idx)
      end
    end)
  end

  defp get_initial_state() do
    start = Timex.now()

    posts = File.ls!("priv/posts")
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.filter_map(&(Path.extname(&1) == ".md"), &Post.compile/1)
    |> Flow.partition
    |> Flow.reduce(fn -> [] end, &valid_into_list/2)
    |> Enum.sort(&sort/2)

    Logger.debug "Compiled #{Enum.count(posts)} posts in #{Timex.diff Timex.now(), start, :milliseconds}ms."

    posts
  end

  defp valid_into_list(item, acc) do
    case item do
      {:ok, post} -> acc ++ [post]
      {:error, _} -> acc
    end
  end

  defp sort(a, b), do: Timex.compare(a.date, b.date) > 0
end
