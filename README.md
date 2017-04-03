---
title: Jelly Shot
separator: <!--s-->
verticalSeparator: <!--v-->
theme: black
revealOptions:
    controls: false
    transition: 'slide'
---

#  Jelly Shot ![CircleCI](https://circleci.com/gh/erikmueller/jelly_shot/tree/master.svg?style=svg) <!-- .element style="border: none; background: none;" -->

A semi static blog engine


<!--s-->

## starting point

Static markdown blog by
[@seilund](http://www.sebastianseilund.com/static-markdown-blog-posts-with-elixir-phoenix)

<!--s-->

### A million static site generators...
### 💁 let's write another one <!-- .element: class="fragment" -->

<!--s-->

* Phoenix
* No database <!-- .element: class="fragment" -->
* No static file generation <!-- .element: class="fragment" -->

<!--s-->

* Compiling [markdown](https://github.com/pragdave/earmark) into `%Post{}`s
* Have a [GenServer](https://hexdocs.pm/elixir/GenServer.html) deliver them

<!--s-->

### Let's take this further

* Generator __`->` markdown `|>` struct__ <!-- .element: class="fragment" -->
* Repository __`->` [Agent](https://hexdocs.pm/elixir/Agent.html) storing data__ <!-- .element: class="fragment" -->
* Watcher __`->` [GenServer](https://hexdocs.pm/elixir/GenServer.html) for auto update__ <!-- .element: class="fragment" -->

<!--s-->

#### Generator

```elixir
defp compile_file(file) do
  with{:ok, matter, body} <- split_frontmatter(file),
      {:ok, html, _} <- Earmark.as_html(body),
  do: {:ok, into_post(file, matter, html)}
end
```

```elixir
defp into_post(file, meta, html) do
  data = %{
    slug: file_to_slug(file),
    content: html,
  } |> Map.merge(meta)

  struct(JellyShot.Post, data)
end
```

<!--s-->

#### Repository

```elixir
def start_link do
  Agent.start_link(&get_initial_state/0, name: __MODULE__)
end
```

```elixir
posts = File.ls!("priv/posts")
|> Enum.filter(&(Path.extname(&1) == ".md"))
|> Enum.map(&compile_async/1)
|> Enum.map(&Task.await/1)
|> Enum.reduce([], &valid_into_list/2)
|> Enum.sort(&sort/2)
```

<!--s-->

#### Watcher

```elixir
def init(state) do
  path = Path.expand("priv/posts")

  :fs.start_link(:fs_watcher, path)
  :fs.subscribe(:fs_watcher)

  {:ok, state}
end
```

```elixir
def handle_info({_pid, {:fs, :file_event}, {path, ev}}, _) do
  new_state = cond do
    Enum.member?(ev, :modified) ->
      path
      |> JellyShot.Post.file_to_slug
      |> JellyShot.Repo.upsert_by_slug
  end
end
```

<!--s-->

### Integrating into Phoenix 🐣🔥

<!--s-->

#### Listing posts

```elixir
def index(conn, params) do
  {tmpl, headline, {:ok, posts}} = case params do
    %{"author" => author} ->
      {"list", "by author",  Repo.get_by_author(author)}
    %{"category" => category} ->
      {"list", "by category", Repo.get_by_category(category)}
    _ ->
      {"index", "recent posts", Repo.list()}
  end

  render conn, "#{tmpl}.html", head: head, posts: posts
end
```

<!--s-->

![JellySHot](./jelly_shot.png)

<!--s-->

## Limitations

<!--s-->

### Filling the repository...

~ 250 sloc / file

* 12 posts in 406ms 🐰 <!-- .element: class="fragment" -->
* 384 posts in 3844ms 🐢 <!-- .element: class="fragment" -->
* ... 🐌 <!-- .element: class="fragment" -->

We might hit a cap at some point <!-- .element: class="fragment" -->
<!--s-->

### Anyway, I Learned a lot

* __Pattern matching__ <!-- .element: class="fragment" -->
* `Agents` <!-- .element: class="fragment" -->
* `GenServer` <!-- .element: class="fragment" -->
* `with {:ok}` <!-- .element: class="fragment" -->

<!--s-->

# Thanks

[https://github.com/erikmueller/jelly_shot](https://github.com/erikmueller/jelly_shot)

<style>
  .reveal code {font-family: hasklig, monospace}
</style>
