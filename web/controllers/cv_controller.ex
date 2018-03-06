
alias JellyShot.CVRepository, as: CV

defmodule JellyShot.CVController do
  use JellyShot.Web, :controller

  def show(conn, _) do
    render conn, "show.html", content: CV.get()
  end
end
