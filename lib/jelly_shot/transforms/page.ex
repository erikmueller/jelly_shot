require Logger

defmodule JellyShot.Page do
  def transform(file) do
    file_name = file |> Path.basename |> String.replace(Path.extname(file), "")

    case Earmark.as_html(File.read!(file)) do
      {:ok, html, _} -> {:ok, %{file_name => html}}
      {:error, reason} ->
        Logger.warn "Failed to compile Page, #{reason}"

        {:error, reason}
    end
  end
end
