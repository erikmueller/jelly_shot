---
title: "Server-side React Routing with Elixir"
date: "2018-05-23"
image: /assets/space.jpg
intro: "Whether you love it or hate it, you can hardly ignore react and its ecosystem nowadays.
React is (just) JavaScript (if you strip away JSX & friends) and not everyone has (or is willing to have) a JavaScript background. When you finally decide to build your frontend with React you still need some backend that is delivering the inital page. Let's say we want to create a more resilient backend and use Elixir as an example implementation. This leaves us with a couple of problems for our undertaking that need to be solved."
categories: ["elixir", "javascript"]
authors: ["Erik"]
---

Whether you love it or hate it, you can hardly ignore react and its ecosystem nowadays.
React is (just) JavaScript (if you strip away JSX & friends) and not everyone has (or is willing to have) a JavaScript background.
Unfortunately there is some further obstacles on the road to an efficient universal React app.
When you finally decide to build your frontend with React you still need some backend that is delivering the inital page.
That's where it gets tricky.
You want to render your first page view on the server (for SEO reasons) and afterwards continue navigation as a SPA.
This means that you need some kind of synchronisation between you client-side routes and your server-side routes.
Of course you only want to define them once.
As you only want to write your views once too, you probably end up writing the backend for your frontend (BFF) as some kind of node app since that's the only way to render (and route) your React components.
Although node (with express or hapi) lets you create apps and APIs pretty fast and straightforward it lacks concurrency and proper failover strategies out of the box.
Let's say we want to create a more resilient backend and use Elixir as an example implementation.
This leaves us with a couple of problems for our undertaking that need to be solved.

* Have one place to define our routes used by client and server
* Render our react components on client and server
* Use something else than node on the backend (because it would be too easy otherwise)

There's some stuff to do so let's go to work, shall we.

## Forging the resilient backend

Before we can go and implement our shiny react app we need someone to deliver the inital html page with the script tags.
This will allow React to do its magic on the frontend.
In the first step we will create a lean HTTP server using [Plug](https://github.com/elixir-plug/plug), _a specification and conveniences for composable modules between web applications_.
We need our router to do the following things:

* Deliver static assets to the frontend (e.g. a webpack js bundle)
* Render a static html template with a script tag loading the bundle
* Bonus: Split requests between view rendering and API (for later)

This looks something like the following:

```elixir
defmodule My.Router do
  use Plug.Router

  plug Plug.Static,
    at: "/static",
    from: "priv/static"

  plug :match
  plug :dispatch

  forward "/api", to: Luke.ApiRouter
  forward "/", to: Luke.ReactRouter
end
```

Let's break down the above building blocks (plugs).
`Plug.Static` is used to serve everything under `priv/static` at the `static` route to the client.
The two plugs `:match` and `:dispatch` are needed to match routes and invoke the appropriate handler (plug) via the `forward` functions right underneath.
Voila, our router is ready to accept requests.
However, before we can respond we need to create the two mentioned sub routers for handling API and view requests.

For our API router we only do a dummy implementation.

```elixir
defmodule My.ApiRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    send_resp conn, 501, "Not implemented"
  end
end
```

Each request arriving on `/api` gets forwarded to that router and will therefore be confirmed with a friendly 501: Not imaplemented.
The frontend (or better react) router will do something quite similar with two differences.
Instead of a generic `match` we are only interested in `get` requests and we're even more frindly since we're going to render a real nice template with status 200.
Using Embedded Elixir (EEx) templates we can create a module that can magically create a template function from a file

```elixir
defmodule My.Render do
  require EEx

  EEx.function_from_file(:def, :index, "index.html.eex", [:html])
end
```

This gives us an `index` function that receives an `html` parameter which is then injected in the template.
Besides the usual HTML tags we will also be including a script tag for our react app later.
Speaking of which, now would be a good time the write that one

## Creating a simple React (frontend) App using react router

We'll be using react-router v4 for client-side routing.
It comes with components that let you declaratively define your routes in JS(X).
Consider the following setup

```js
const { createElement: h } = require('react')
const { Route, Switch } = require('react-router')

const App = () => {
  return h(
    Switch,
    null,
    h(Route, { exact: true, path: '/', component: Home }),
    h(Route, { path: '/a', component: A }),
    h(Route, { path: '/b', component: B }),
    h(Route, { component: NotFound })
  )
}
```

This defines four routes.
Three of them render normal views while one (`NotFound`) serves as a 404 page.
With `webpack` or the likes we're able to create the bundle which we can statically put into our template delivered by the server.
Given components `A` and `B` have some react-router `Link`s to jump around we already have a client-only SPA.

Now we're using this exact same app with its routing on the server.
Prepare for some awesomeness.

## JSON is your new best friend

Michael Jackson (the react guy, not the pop guy) created a little project called [react-stdio](https://github.com/ReactTraining/react-stdio).
It let's you render react components by passing the path to the component as well as a props object via STDIN and get back the rendered output through STDOUT.
This lets you use react with every language that can spawn process and communicate through standard streams with a JSON protocol.
Luckily [Roman Chvanikov wrote a great article](https://medium.com/@chvanikoff/lets-refactor-std-json-io-e444b6f2c580) on a refactoring of [std_json_io](https://github.com/hassox/std_json_io), a convinient library for communicating with an external script via JSON.
This is no coincidence since `std_json_io` was [originally written for react-stdio](https://evalcode.com/render-react-with-phoenix/)).

While this was enough to render simple components it was a bit tricky to actually do routing.
Besides returning the output stream you also have to somehow inform the server about the result of react-router's matching.
After some fiddeling around and a [PR](https://github.com/ReactTraining/react-stdio/pull/13/files) that michael accepted, react-stdio now also returns a `context` for exactly that (and other abuses).

Heading back to our elixir implementation of the frontend router we can pimp that a little.

```elixir
...
  case StdJsonIo.json_call(%{
    "component" => "web/react-router.js",
    "props" => %{
      "location" => conn.request_path
    }
  }) do
    {:ok, %{"html" => html, "context" => context}} ->
      send_resp(conn, context["status"] || 200, My.Render.index(html))
    {:error, %{"message" => message}} ->
      send_resp(conn, 500, Render.index(message))
    {:error, error} ->
      send_resp(conn, 500, Render.index(error))
  end
...
```

Instead of just returning our template we're going to return the rendered match of our routing definition.
For react-router to be working correctly we only need one prop.
The current request path.
We're calling `StdJsonIo` with the path to our entry point and the current location (aka request path).

```js
const { createElement: h } = require('react')
const { StaticRouter } = require('react-router')
const App = require('./static/App.js')

const context = {}
const Router = ({ location }) => h(StaticRouter, { location, context }, h(App))

Router.context = context
module.exports = Router
```

Notice the `context` that is passed to the `StaticRouter` and exposed vie the exported `Router`.
This is the key of sending the correct status to the client.
Since the `ReactRouter` plug will assume a status code of 200 until told otherwise, we only have to set it in case of something going wrong.
Remember out `NotFound` component that is rendered when no rout matches?
Here is what it actually does

```jsx
const NotFound = ({ staticContext = {} }) => {
  staticContext.status = 404

  return h('h3', null, 'Sorry, we took a wrong turn.')
}
```

It sets enhances the context with a status code (that is not 200) which is handled by the `StaticRouter` and then exposed.
Ignoring the various error cases (timeout, syntax, ...) that are handled by our above ReactRouter plug we ca see a patternmatch for the actual content (`html`) and our `context`.

```elixir
...
  {:ok, %{"html" => html, "context" => context}} ->
    send_resp(conn, context["status"] || 200, Render.index(html))
...
```

## We're done. Lets recap

Every (GET) request (that is not `/api/*`) is forwarded to our ReactRouter plug.
Here we're rendering our `react-router.js` entrypoint which uses the same `App` as the frontend.
`StdJsonIo` takes care of serialising and deserialising our JSON communication through `react-stdio`.
We can then render our EEX template with the delivered render output and set the response's status according to react-router's matching result (via context).

You can find the complete code on [Github](https://github.com/erikmueller/luke)] together with links to all the resources mentioned here.
