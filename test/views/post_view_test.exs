defmodule JellyShot.PostViewTest do
  use JellyShot.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders meta.show.html" do
    post = %{
      post: %{
        slug: "test_slug",
        title: "test_title",
        intro: "test_intro"
      }
    }

    assert render_to_string(
      JellyShot.PostView,
      "meta.show.html",
      post
    ) == """
      <title>test_title</title>
      <meta name="description" content="test_intro" />
      <link rel="canonical" href="https://blog.com/blog/posts/test_slug"/>
    """
  end
end
