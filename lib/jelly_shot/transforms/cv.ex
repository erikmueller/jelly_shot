require Logger

defmodule JellyShot.CV do
  def transform(file) do
    case Earmark.as_html(File.read!(file)) do
      {:ok, html, _} -> {:ok, html}
      {:error, reason} ->
        Logger.warn "Failed to compile CV, #{reason}"

        {:error, reason}
    end
  end
end
