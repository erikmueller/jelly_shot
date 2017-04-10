defmodule JellyShot.PostTest do
  use ExUnit.Case
  alias JellyShot.Post

  test "generate" do
    test_file = "test/support/test_file.md"

    assert {:ok, %Post{
      authors: ["Erik"],
      categories: ["test"],
      content: "<h1>This</h1>\n<p><em>is</em> <strong>markdown</strong>!</p>\n",
      date: ~N[2015-10-28 00:00:00],
      image: "/assets/nature.jpg",
      intro: "test intro",
      slug: "test_file",
      file: test_file,
      title: "test post"
    }} = Post.generate(test_file)
  end

  test "fail to generate" do
    file_not_found = "test/support/file_not_found.md"
    file_invalid_frontmatter = "test/support/file_invalid_frontmatter.md"
    file_invalid_date = "test/support/file_invalid_date.md"

    assert {:error, :enoent} = Post.generate(file_not_found)
    assert {:error, :invalid_front_matter} = Post.generate(file_invalid_frontmatter)
    assert {:error, "Expected `4 digit year` at line 1, column 1."} = Post.generate(file_invalid_date)
  end
end
