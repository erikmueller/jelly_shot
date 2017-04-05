defmodule JellyShot.PostTest do
  use ExUnit.Case
  alias JellyShot.Post

  test "file_to_slug" do
    assert Post.file_to_slug("/test/support/test-file.md") == "test-file"
  end

  test "generate" do
    assert {:ok, %Post{
      authors: ["Erik"],
      categories: ["test"],
      content: "<h1>This</h1>\n<p><em>is</em> <strong>markdown</strong>!</p>\n",
      date: ~N[2015-10-28 00:00:00],
      image: "/assets/nature.jpg",
      intro: "",
      slug: "test_file",
      title: "test post"
    }} = Post.generate("test_file.md")
  end

  test "fail to generate" do
    assert {:error, :enoent} = Post.generate("file_not_found.md")
    assert {:error, :invalid_front_matter} = Post.generate("file_invalid_frontmatter.md")
    assert {:error, "Expected `4 digit year` at line 1, column 1."} = Post.generate("file_invalid_date.md")
  end
end
