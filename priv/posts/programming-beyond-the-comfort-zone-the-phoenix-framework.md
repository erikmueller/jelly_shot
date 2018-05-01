---
title: "The Phoenix Framework: Programming beyond the comfort zone"
date: "2017-02-10"
image: /assets/fire.jpg
intro: "In the last post we checked why you should learn some more languages and why Elixir might help you becoming a better JavaScript developer. Now I promised to go deeper into web development. A popular (if not the most popular) web framework for Elixir is Phoenix."
categories: ["elixir"]
authors: ["Erik"]
---

I'm a JavaScript Engineer.
I write JavaScript.
I really like writing JavaScript and I feel very comfortable doing so.
In the JavaScript world, there are a gazillion web frameworks available and every week there are more coming.
Besides the usual suspects like `express` and `hapi`, there are a lot of things that are fun to play with like zeit's `micro`.
Although having some different concepts, they all have something in common: They're (of course) JavaScript frameworks.
Now, if you want to learn more about the HTTP stack or the request and response cycle, you should definitely check out a lot of different frameworks since different concepts give you different insights and perspectives of the inner workings.

So why should you start programming in another language?

Let's take a step back from the frameworks and look at the language itself.
JavaScript claims to be both, object-oriented (with prototypal inheritance) and functional.
And since it claims to be both, it is neither one nor the other to a satisfying extend.
Other languages like [Elixir](http://elixir-lang.org/){:target="\_blank"} (which we're going to talk about in a bit) make it much easier to use functional language features and methods such as _destructuring_, _pattern matching_ or _recursion_.
You might shift from doing everything with a `forEach` loop to solving pretty much every problem with `reduce`.
This paradigm shift not only broadens your programming knowledge, but lets you view problems (and more importantly their solutions) from a different angle.
On top of that, it improves code readability - at least most of the time 😉.

Now, what if I told you that you can learn all of this by using a web framework (and language) that is not only fun to work with but also faster and less error prone than all of the before mentioned?

## Enter: Elixir and Phoenix

This is rather a teaser that should make you curious about trying out something new and leaving your comfort zone, than a full blown tutorial or language reference.
This first part will take a look at how **Elixir** might help you to rethink programming patterns leading to cleaner code and continue with what this [**Phoenix**](http://www.phoenixframework.org/){:target="\_blank"} thing actually is.

### The Platform

Before we explore some Elixir code, let's start with a naive JS example of populating an array - mutation style.

```js
const myNumbers = [-2, 3, 5, -34, 0, 32]
const result = []

myNumbers.forEach(num => {
  if (num > 0) {
    result.push(num * 2)
  }
})
```

So what do we have here? Side effects and mutation! With each iteration we're changing the `result` array. In this simple case we're pretty sure that we know what it contains after we touched each number. With higher complexity (and nesting) we might be guessing the values rather than knowing them. Furthermore it's not quite obvious at first sight how `result` is populated (because there's no assignment we can see right away).

Of course we can do better:

```js
const myNumbers = [-2, 3, 5, -34, 0, 32]
const result = myNumbers.filter(num => num > 0).map(num => num * 2)
```

This time we see that `result` will contain the double of all positive numbers from the source array.
Way more explicit, isn't it?
For the record, this is how the above would look in Elixir:

```elixir
my_numbers = [-2, 3, 5, -34, 0, 32]
result = my_numbers
    |> Enum.filter(fn (num) -> num > 0 end)
    |> Enum.map(&(&1 * 2))
```

This pretty much resembles the JavaScript solution, right?!
Almost!
Since Elixir is based on immutable data, you could not have started as shown in the first JavaScript solution.
You cannot simply mutate a data structure in Elixir!
What you would have done is to create a new list with every value from the old one that you see fit.
Besides that, there are some other oddities.
The `|>` is called a pipe operator and passes the value as the first argument to the next function.
While we're using the `fn` keyword to define an anonymous function as the `filter` expression and explicitly naming the variable `num`, we're shortening this for the `map` function and just say: "_This function uses the first argument (`&1`) it receives and doubles it_".

Let's take the example from above again.
In contrast to JavaScript, we can use some sugar in Elixir called a `for` comprehension in conjunction with a filter to loop over the enumerable and create a new one (with all values > 0 doubled).

```elixir
my_numbers = [-2, 3, 5, -34, 0, 32]
result = for n <- my_numbers, n > 0, do: n * 2
```

Note that the last statement of every Elixir function is automatically returned creating a new list bound to `result`.
What actually looks like an assignment `=` is actually a `match`.
Trying to match `result = 4` afterwards will give you an error, since the compiler tries to match `[6, 10, 64] = 4`.
This might look strange at first, yet makes more sense once you grasp concepts like pattern matching or destructuring.

After looking at the above described language features, I cannot circumvent a few basic facts.
Elixir runs on the [Erlang](https://www.erlang.org/){:target="\_blank"} VM (BEAM) and gives you the great ecosystem companies like _Heroku_ and _WhatsApp_ use to build their products.
It kind of relates to Erlang like Scala relates to Java (JVM).
Likewise, you can import Erlang modules and use them right away.
Elixir's syntax is concise and reminds of the Ruby programming language due to the fact that the creator [José Valim](https://github.com/josevalim){:target="\_blank"} is a very active member of the ruby community.

Ok, let's see some more Elixir code and compare it to JavaScript ES6.

Elixir

```elixir
# Printing the sum of a list
Enum.reduce([1, 2, 3, 5, 8], fn(item, acc) -> acc + item end) |> IO.puts

# or without explicitly naming the parameters
Enum.reduce([1, 2, 3, 5, 8], &(&1 + &2)) |> IO.puts
```

JS

```js
// Printing the sum of an array
console.log([1, 2, 3, 5, 8].reduce((acc, item) => acc + item))
```

Elixir

```elixir
# And we all love fibonacci right?
defmodule Fibonacci do
    def calc (n) when n < 2, do: 1
    def calc (n), do: calc(n - 2) + calc(n - 1)
end
```

JS

```js
// We all do love fibonacci!
function fibonacci(n) {
  if (n < 2) return 1

  return fibonacci(n - 2) + fibonacci(n - 1)
}
```

### Enough of the platform

At this point I'll stop listing language features Elixir provides since this post is only meant for sweetening.
I will also not try to persuade you that this is the right language to learn and use.
Anyway, you should probably check some resources and dive a bit deeper into the awesome world of functional programming.
A good place to start is [the official elixir-lang site](http://elixir-lang.org/){:target="\_blank"}.
Just click around and look at some beautiful code and examples.

You think Elixir is not for you?
Check out another functional language then!
Take a look at [Scala](https://www.scala-lang.org/){:target="\_blank"}, [Haskell](https://www.haskell.org/){:target="\_blank"} or Erlang itself.
I personally think your daily (programming) life will benefit from everything you learn, even if you do not actively use these languages for development.

**Next up**: The Phoenix web framework.
See how it works and which concepts and tools it uses to keep your project bloat-free, how it makes your development faster and delivers responses within microseconds.
