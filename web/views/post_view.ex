defmodule Frozen.PostView do
  use Frozen.Web, :view

  def render("meta.show.html", %{post: post}) do
    %{slug: slug, title: title, intro: intro} = post

    ~E"""
      <title><%= title %></title>
      <meta name="description" content="<%= intro %>" />
      <link rel="canonical" href="https://blog.com/blog/posts/<%= slug %>"/>
    """
  end
end
