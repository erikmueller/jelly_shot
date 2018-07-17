require Logger

defmodule JellyShot.Post do
  defstruct file_name: "", slug: "", authors: [], title: "", date: "", intro: "", categories: [], image: "", image_position: "center", content: ""

  def transform(file) do
    case do_transform(file) do
      {:ok, post} -> {:ok, post}
      {:error, reason} ->
        Logger.warn "Failed to compile #{file}, #{reason}"

        {:error, reason}
    end
  end

  defp do_transform(file) do
    with{:ok, matter, body} <- split_frontmatter(file),
        {:ok, html, _} <- Earmark.as_html(body),
    do: {:ok, into_post(file, matter, html)}
  end

  defp split_frontmatter(file) do
    with{:ok, matter, body} <- parse_yaml_frontmatter(file),
        {:ok, parsed_date} <- Timex.parse(matter.date, "{ISOdate}"),
    do: {:ok, %{matter | date: parsed_date}, body}
  end

  defp parse_yaml_frontmatter(file) do
    case YamlFrontMatter.parse_file(file) do
      {:ok, matter, body} ->
        {:ok, Map.new(matter, fn {k, v} -> {String.to_atom(k), v} end), body}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp file_to_slug(file) do
    file |> Path.basename(file) |> String.replace(~r/\.md$/, "") |> URI.encode
  end

  defp into_post(file, meta, html) do
    data = %{
      file_name: file,
      slug: file_to_slug(file),
      content: html,
    } |> Map.merge(meta)

    struct(JellyShot.Post, data)
  end
end
