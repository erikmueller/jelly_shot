require Logger

defmodule Frozen.Post do
  defstruct slug: "", authors: [], title: "", date: "", intro: "", categories: [], content: ""

  def file_to_slug(file) do
    file |> Path.basename(file) |> String.replace(~r/\.md$/, "")
  end

  def compile(file) do
    Path.join(["priv/posts", file])
    |> split_frontmatter_markdown
    |> into_post
  end

  defp split_frontmatter_markdown(file) do
    case YamlFrontMatter.parse_file(file) do
      {:ok, frontmatter, markdown} ->
        case Timex.parse(frontmatter["date"], "{ISOdate}") do
          {:ok, parsed_date} ->
            {file, Map.put(frontmatter, "date", parsed_date), Earmark.as_html!(markdown)}
          {:error, _} ->
            {:error, "Failed to compile #{file}. Reason invalid_date"}
        end
      {:error, reason} ->
        {:error, "Failed to compile #{file}. Reason #{reason}"}
    end
  end

  defp into_post({:error, reason}), do: {:error, reason}

  defp into_post({file, frontmatter, content}) do
    {:ok, %Frozen.Post{
      slug: file_to_slug(file),
      title: frontmatter["title"],
      authors: frontmatter["authors"],
      date: frontmatter["date"],
      intro: frontmatter["intro"],
      categories: frontmatter["categories"],
      content: content
    }}
  end
end
