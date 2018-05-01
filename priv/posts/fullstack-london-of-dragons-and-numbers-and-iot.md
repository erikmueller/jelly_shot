---
title: "Fullstack London - Of dragons, numbers and IoT"
date: 2017-07-20
image: /assets/dragon.jpg
intro: "After one year of abscence I was attending Fullstack London again. The past years were well-organized, fun, and had an awesome speaker deck on top of that. This year was no difference. Here are some things I took away from these awesome three days."
categories: ["javascript"]
authors: ["Erik"]
---

After one year of abscence I was attending [Fullstack](https://skillsmatter.com/conferences/8264-fullstack-2017-the-conference-on-javascript-node-and-internet-of-things){:target="\_blank"} London again. The past years were well-organized, fun, and had an awesome speaker deck on top of that.
This year was no difference.

Here are some things I took away from these awesome three days.

## Keynotes and workshops

The opening keynote was held by [Douglas Crockford](https://github.com/douglascrockford){:target="_blank"} (the father of JSON) himself.
While talking about numbers and their history he came up with [DEC64](http://dec64.com/){:target="\_blank"}, a new number type that fixes truncation and overflow problems (besides others) originated in the fifties.
The session was not only informative but also very humorous as Crockford is often very opinionated and does not try to hide that at all.
On top of that, [Skills Matter](https://skillsmatter.com){:target="\_blank"} gave away (among other things to choose from) Crockfords \_The Good Parts_ book which he signed during the conference.

Later that day [Amie D. Dansby](https://twitter.com/amiedoubleD){:target="\_blank"}, an Iot enthusiast and maker (with an RFID chip in her hand and a remarkable resemblance to NCIS' Abby), gave an inspiring talk about releasing your inner maker.
IMHO her slides where a bit overloaded but her spirit and message as well as the content (maybe because of the massive content) totally made up for that!
She was also the one giving a hands on IoT workshop with Onion's [Omega2](https://onion.io){:target="\_blank"} development board.
After DDoS'ing the conference's Wi-Fi frequencies and some struggle for more space on the board I managed to get a working Twitter wearable displaying my latest tweet on an OLED display (and thanks to Amie's patience).

There were several other inspiring keynotes including SitePen's [Dylan Schiemann](https://twitter.com/dylans){:target="\_blank"} (wearing a Dojo 2.0 t-shirt) about the state of JavaScript and a talk about progressive web apps by [Chris Heilmann](https://twitter.com/codepo8){:target="\_blank"}.
Although I thought the whole PWA topic is talked about too much, Chris did a pretty good job outlining what really matters when progressively enhance web sites (and apps).
[Myles Borins](https://twitter.com/MylesBorins){:target="\_blank"} shared some insights on how Node.js releases work and made me finally realize why a staging branch is called a staging branch: Because you push releases while on stage.

Afterwards there where several tracks in parallel.
No matter if it's conference talks or festival bands: They're either of the _don't-care-could-go-anywhere_ kind or you want to attend all simultaneously.
As hard as it was I managed to single out some interesting sessions since I knew I could (and you can too) watch the others from the [skills cast](https://skillsmatter.com/conferences/8264-fullstack-2017-the-conference-on-javascript-node-and-internet-of-things#program){:target="\_blank"} later.

## TypeScript decorators

Thanks to [@thekwasti](https://twitter.com/thekwasti){:target="\_blank"} I recently started writing some TypeScript (or rather screwing with the TS he wrote).
I also know decorators (for the spec has been deprecated and was still not reintroduced).

[Damjan Vujnovic](https://twitter.com/returnthis){:target="_blank"} was (accidentally) picking up Crockford's \_numbers_ theme while doing his (vivid) introduction.
Decorators are an excellent way to let all of your functions be responsible for a single purpose and "inject" every other (reusable) behavior, such as logging or measuring.
This insight does not only apply to TypeScript but can also be used when decorators come (back) to the JavaScript language since they are basically sugar for higher-order functions.

The most interesting example was a timeout decorator that could be used to let an async operation fail if it took longer than specified.
Therefore, the decorator let the original async operation race against a delayed rejecting promise.
If the operation completed before the rejecting promise it was considered successful.
As soon as it took longer, the delayed promise would reject and fail the whole operation marking it as timed out.

## npm vs gulp vs webpack vs what the heck!?

Although we're using all of these tools in daily development and this was labeled a beginner session, [Rubén Sospedra](https://twitter.com/sospedra_r){:target="\_blank"} made you rethink the usage scenarios of the above mentioned.

It was no _X_ is better than _Y_ is better than _Z_ talk which I was very grateful for.
Every tool has its right to exist and should be used accordingly.
Use npm for specifying simple commands or commands that trigger a chain of commands (a pipeline).
Then specify complex pipelines with gulp (or any task runner that is hip at the time of reading).
Finally, let webpack (or rollup or one of [substack's](https://github.com/substack){:target="\_blank"} epic projects) take care of bundling your application.

## Blockchain 101

Since the rise of Bitcoin everybody heard about crypto currencies and a mysterious construct that is the blockchain.
IBM's [Kevin Hoyt](https://twitter.com/krhoyt){:target="\_blank"} did a great job demystifying this "distributed database with special properties".
And that's what it is (basically).
When you think about it, the whole Internet could be built on blockchain technology 🤔 😱.

Watch the [skills cast](https://skillsmatter.com/skillscasts/10360-understanding-blockchain){:target="\_blank"}, it'll open your eyes.

## Benchmarking and performance

There were two talks I attended that dealt with performance and how to measure it.

> Sometimes measuring performance is art rather than science.

The above quote's author [Ahmad Nassri](https://twitter.com/AhmadNassri){:target="\_blank"} laid out a pretty relevant case of measuring function call performance especially in the time of AWS, Azure and GCE.
The faster your function executes in these environments the lesser you pay.
It's that easy.
Not only should benchmarking be part of the after-release phase (which is basically monitoring at that point) but also during the development cycle.
However, do not overdo optimizing (especially not premature).

[Martin Splitt](https://twitter.com/g33konaut){:target="\_blank"}, on the other hand, shed some light on browser rendering performance.
He took the audience from 3 little shining dots all the way to how (and most importantly when) browsers are rendering a web page.
Some explanations (especially GPUs and shaders) reminded me a lot of some profs' lectures back at university (meaning he did a pretty good job IMHO).
Best takeaway: Avoid the green rectangle of sadness!
Avoid everything that makes the browser relayout or repaint (since these are the most expensive operations) but keep an eye on memory consumption.

## Dragons in London...

...or how you should design an awesome test task to hire new developers.
BigBank's [Nele Sergejeva](https://twitter.com/nelesergejeva){:target="\_blank"} was elaborating on mistakes you can make (as an interviewer as well as the one interviewed) when it comes to finding new developers (or a company to work for).
She was (in either way) clearly advocating for story-telling.
The test she presented was indeed way better than all I have done (or created) so far.
It is not something abstract or technical but it gives you the impression you're solving a real (well actually fictional) problem.
Furthermore, it requires you to solve tasks like coping with REST APIs (and there sometimes interesting responses) as well as designing a simple algorithm.
Especially when having started a new programming language this makes you dive into the fundamentals with a lot of pleasure and freedom (since the task is not as strict on how to exactly solve it).

Checkout how to help the [Kingdom of Mugloar](http://dragonsofmugloar.com){:target="\_blank"} as Head of Dragon Resources Management.

## Async architecture

The one & only [Tomasz Ducin](https://twitter.com/tomasz_ducin){:target="\_blank"} had the slot for the last talk of the day before the workshops began.
And here I thought I knew about async programming in JavaScript!

* Callbacks? Sure, I heard there even was a hell for them.
* Promises? Doing that all day.
* Reactive streams? Recently tried some in Elixir.
* Generators? Yeah, heard they exist.
* Async/Await? Was experimenting with that.

What about croutines?
Co-What?
Well, turned out I didn't know that the latter two are actually part of coroutines, and I used them without knowing.
It also featured the best explanation of `yield` so far:

> `yield` is doing the same as a _Mortal Combat_ fatality. It's taking the promise and ripping out it's heart (value).

Basically the talk was glueing together my knowledge (fragments) of async operations making me understand a lot of connections and things they all have in common (and share).
Although Tomasz had to rush a bit during the end it's definitely to recommend especially to people coming to node.js since it also explains the (simplified) workings of the event loop and asynchronicity in general.
