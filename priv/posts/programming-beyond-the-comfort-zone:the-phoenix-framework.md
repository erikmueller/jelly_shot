---
layout: post
title: "Programming beyond the comfort zone: The Phoenix Framework"
date: "2017-02-09"
image: /assets/paula.jpg
intro: "In the last post we checked why you should learn some more languages and why Elixir might help you becoming a better JavaScript developer. Now I promised to go deeper into web development. A popular (if not the most popular) web framework for Elixir is Phoenix."
categories: ["elixir"]
authors: ["Erik"]
---

In the [last post](https://developer.epages.com/blog/2017/02/02/programming-beyond-the-comfort-zone-javascript-elixir.html) we checked why you should learn some more languages and why Elixir might help you becoming a better JavaScript developer.
Now I promised to go deeper into web development (since this is what JS devs do, right?).
A popular (if not the most popular) web framework for Elixir is [**Phoenix**](http://www.phoenixframework.org/).
After a short overview and a look at it's core concepts we're going to build a (very) small REST API just to check how to start and how this start looks like.
I'm sure you'll find hundreds of more sophisticated tutorials out there on the internet if you want to go further.

## Overview

Started by Chris McCord, the [Phoenix Framework](http://www.phoenixframework.org/) released version [1.0](https://github.com/phoenixframework/phoenix/releases/tag/v1.0.0) in August 2015.
This was one and a half year after the famous *[initial commit](https://github.com/phoenixframework/phoenix/commit/c4ede8c5f71ab74b0c2e9de1eb37d15531d95a46)* we all know {% emoji wink %}.
Now it's not only used for dynamic websites and applications but especially advertised for real-time WebSocket-based interaction (e.g. chats, games, etc).

Phoenix is heavily relying on three (Elixir and/or Erlang) projects:

1. The HTTP server [Cowboy](https://github.com/ninenines/cowboy)
2. [Plug](https://github.com/elixir-lang/plug) - a specification for composable modules used in web application
3. The database wrapper [Ecto](https://github.com/elixir-ecto/ecto) which also provides a DSL for querying.

Since Phoenix is built in a very modular way you can add and remove pretty much any functionality you need.
Writing a REST API that only provides JSON data?
Simply remove the template logic and the complete frontend asset pipeline!
This gives you a project structure that fits your needs and doesn't bloat your application.

## What makes the bird fly

So now that we know what big pieces are used to compose the framework let's see how Phoenix comes from an incoming request to an outgoing response.
The most important thing to notice is that within the framework (and it's layers) you will always see a *connection* or `conn` being passed around and altered.
Of course you do not alter the *original* connection but rather use it to construct a new one.
Remember, we have immutable data!

To give you a more visual impression of the flow I'd like to borrow some thoughts from the excellent ["Programming Phoenix"](https://pragprog.com/book/phoenix/programming-phoenix) book.
As mentioned we start with the `connection`.
In case you forgot, the pipeline operator `|>` takes the left-hand side and passes it as the first argument to the function on the right.

```elixir
Connection
|> Endpoint
|> Router
|> Controller
```

First we hit the **Endpoint**.
This is the place where, in the Express world, you define your `app()` and `use()` different kinds of middleware layers.
In Phoenix these layers are specified by different **Plugs**.
A plug can be anything from a logger to different header definitions or session handling.
Right after the endpoint (entrypoint) comes the **Router**.
Pretty much what you would expect: A layer that knows which request should go where - precisely to which **Controller**.
The router can specify **Pipelines** which are usually a series of plugs a request should run through on a specific route.
Think of such a *pipeline* as a stack of middleware with a distinct mount point.
This mechanism e.g. lets you set a JSON accept header for all your `/api/*` routes while all view related requests go through some sort of XSRF protection.

Once our request arrived in the controller we might want to do a call to the database using **Ecto** and pass that data to a **Template** to render it.
Stay with me we're almost there.
The last piece missing is the **View**.
Ever needed some logic in your templates?
Just define everything you need in your corresponding *view* and you can access all functions in your `.eex` template (which stands for embedded elixir and sounds scarier than it is).
We're done.
We just rendered a template with data from our database model.
Incidentally, the model is responsible for defining the database scheme and processing data written to the database (by the controller) and retrieved from the database (also issued by the controller).
You could say that the model is the only one "allowed" to produce side effects and interact with the "outside" world (in our case the database).

## Foreplay

This was a rough overview of the inner workings of Phoenix.
I bet you'd like to see that in action and have a look how we could use this to create an actual real world application.
What would be better than writing a REST API that you can use as a backend for your JavaScript frontend?
Awesome!
There are a couple of things we'll need and since I'm a lazy developer I assume you're running Mac OS.
If not please see the [official Elixir site](http://elixir-lang.org/install.html) to get started.

### TL;DR

```sh
$ brew update && \
  brew install elixir && \
  mix local.hex && \
  mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez && \
  docker run -d -p 5432:5432 postgres && \
  mix phoenix.new rest-api --no-html --no-brunch && \
  cd restapi

```

### The slightly longer version

For Mac OS just get [brew](http://brew.sh/index_de.html) and do a

```sh
$ brew update && brew install elixir
```

which should install both Erlang and Elixir.
If everything went well you can fire up `iex` (Interactive Elixir) in the terminal of your choice and let it print something useful with

```sh
iex(1)> h Map
```
Awesome, we have an interactive shell with integrated documentation 👌.
We have the VM, we have the compiler.
We need some sort of package manager!
Oh, did I mention `mix`?
It's a tool for running tasks like scaffolding, installing dependencies, executing tests, and of course for creating cocktails.
Basically, it's `npm` on steroids.
And it can get us our package manager:

```sh
$ mix local.hex
```

Once we have `hex`, we can get the latest phoenix archive (because we need hex for installing phoenix' dependencies)

```sh
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
```

As we're going to build a tiny REST API we don't need any sort of assets like images, CSS, or JavaScript.
I'm telling you that because Phoenix usually uses **brunch** to compile these statics (which would require `nodejs`).
The only other thing we do need is a database.
The default database Ecto uses is PostgreSQL but you could also opt for MySQL if you like that better.
If you have [Docker](https://www.docker.com/) installed, a simple

```sh
$ docker run -p 5432:5432 postgres
```

will download the image and run your database container on `127.0.0.1:5432` with the user `postgres` and no password.
We're set.
Run

```sh
$ mix phoenix.new rest-api --no-html --no-brunch
```

and agree to install dependencies.
You'll see a couple of files being created.
As well as instructions on how to start the server and how to configure/initialize your database.

## REST API action ahead

Let's be brave and run a one liner

```sh
$ mix ecto.create && mix phoenix.server
```

This will create a new database for development (Phoenix automatically creates suffixed databases for `_dev`, `_test` and `_prod` depending on the environment) and start the server on port 4000.
When opening your browser of choice the first thing you should see when navigating to `https://localhost:4000` is an error message.
Bummer.
Hey, at least it's a beautiful one and it tells you what exactly went wrong.
Remember we told `mix` not to create any html files or bundle static assets?
With that it also did not create any views (except for the error view) or their related routes (e.g. `/`) in the router.
The only scope (and pipeline) we have is `/api` (which is exactly what we wanted).

Let's add a new controller that will serve some `shops` once a request is routed to it.
You could do this by hand or by `mix`, your choice.
The task for generating resources expects you to provide a singular and a plural name as well as some (optional) fields:

```bash
$ mix phoenix.gen.json Shop shops name:string
```

Handy, `mix` not only tells us how to create a route to access this controller it also creates the model including a database migration, a view and tests for all of them (I'm sure now you're glad you `mix`ed it).
We'll do exactly what `mix` suggests and copy the line into our `web/router.ex` (and run `mix ecto.migrate` to update the database).
To check which routes the aforementioned line creates just run `mix phoenix.routes`.
We only want to retrieve a particular shop for this example so we (literally) tell Phoenix: `only: [:show]` instead of `except: [:new, :edit]`.
When we run `mix phoenix.routes` again we should see only one route left.
In this case we could have specified the one route ourselves:

```elixir
get "/shops/:name", ShopController, :show
```

And we will exactly use that line instead of the resource.
First of all it's more explicit and second of all we want the parameter to be `name` anyway (we could also specify this when using a resource but it's simpler this way).
The `:show` atom specifies the controller function to call when this route is accessed.
So let's access `http://localhost/api/shops/foo` and see what happens.

Hooray, the `NoRouteError` is gone, only to give us another one.
Ecto still tries to find our shop in the database by id.
Open the `web/controllers/shop_controller.ex` and check the `show` function.
It expects to get our connection and extracts the `id` from the passed parameters.
Lets extract the `name` instead and tell it to look for it by name since `Repo.get/3` tries to find a match by primary key.

```elixir
def show(conn, %{"name" => name}) do
    shop = Repo.get_by(Shop, name: name)
    render(conn, "show.json", shop: shop)
end
```

You should see something like

```js
{
"data": null
}
```

In case you get an error make sure you ran `mix ecto.migrate` to have Ecto create the `shops` table.
Of course, there's no shop with the name "foo" in our database.
Let's fix that.
Open `priv/repo/seeds.exs` and enter the following:

```elixir
alias Restapi.Repo
alias Restapi.Shop

Repo.insert! %Shop{name: "foo"}

```

The two alias statements let us use `Repo` and `Shop` without prefixing `Restapi`.
Then we simply insert one record (Shop) with the name "foo". Run

```sh
$ mix run priv/repo/seeds.exs
```

to insert the shop.
Accessing `http://localhost/api/shops/foo` again should yield the expected result now.

There's a lot to explore from here on and there's (of course) a lot missing in our little example.

* Check `web/views/shop_view.ex` to see which fields fetched from the database and passed by the controller are actually used to render the view (`updated_at` and `inserted_at` are fetched but don't appear in the response, right?)
* Add some more records in the `seeds.exs` and `GET` them
* Add a route to list all available shops
* Create an HTML application instead of a REST API
* ...

This being probably the smallest and least comprehensive tutorial ever, I encourage you to check the awesome [Phoenix Guides](http://www.phoenixframework.org/docs/overview) which will teach you about everything covered here, and more, in much more depth.
I hope these posts made you curious and showed you some things beyond the JavaScript world.
[Let me know](https://twitter.com/epagesdevs?lang=de) what you think.

Thanks for reading.
foo
foo
foo
