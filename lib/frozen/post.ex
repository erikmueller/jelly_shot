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
      {:ok, frontmatter, markdown} -> {file, frontmatter, Earmark.as_html!(markdown)}
      {:error, reason} -> {:error, file, reason}
    end
  end

  defp into_post({:error, file, reason}) do
    raise "Failed to compile #{file}. Reason #{reason}"
  end

  defp into_post({file, frontmatter, content}) do
    %Frozen.Post{
      slug: file_to_slug(file),
      title: frontmatter["title"],
      authors: frontmatter["authors"],
      date: Timex.parse!(frontmatter["date"], "{ISOdate}"),
      intro: frontmatter["intro"],
      categories: frontmatter["categories"],
      content: content
    }
  end
end
