defmodule Frozen.Post do
  defstruct slug: "", author: "", title: "", date: "", intro: "", content: ""

  def compile(file) do
    post = %Frozen.Post{
      slug: file_to_slug(file)
    }

    Path.join(["priv/posts", file])
      |> File.read!
      |> split_frontmatter_markdown
      |> extract(post)
  end

  defp file_to_slug(file) do
    String.replace(file, ~r/\.md$/, "")
  end

  defp split_frontmatter_markdown(data) do
   {:ok, frontmatter, markdown} = YamlFrontMatter.parse(data)
   {frontmatter, Earmark.as_html!(markdown)}
  end

  defp extract({props, content}, post) do
    %{post |
      title: props["title"],
      author: props["author"],
      date: Timex.parse!(props["date"], "{ISOdate}"),
      intro: props["intro"],
      content: content
    }
  end
end
