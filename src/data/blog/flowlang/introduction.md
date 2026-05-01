---
title: Flowlang Pt.1 - Introduction
pubDatetime: 2024-11-24T12:00:00
tags:
  - flowlang
  - zig
  - interpreter
  - compiler
description:
  I am building my own programming language. It's inspired by Golang and aims to
  be a simple, compiled language. It is implemented in Zig and compiles down to a
  custom bytecode, which is then ran by a stack-based VM.
---

## How did we get here?

Earlier this year, I got interested in writing my own programming language. I
looked around the interwebs© for tutorials and guides and stumbled up this book
by [Robert Nystrom](https://github.com/munificent) called [Crafting Interpreters](https://craftinginterpreters.com/).
I read it and built up my own implementations of `Lox`, the toy-language created
in the book. Nystrom builds a Tree-Walking Interpreter in Java as well as a
Byte-Code VM written in C. I chose different languages I am more familiar with,
namely PHP for the Tree-Walking and Zig for the VM.

The book is very well written and has quite a humorous read to it at times. He
also goes into detail on some historical reason why programming languages turned
out the way they did and references a lot of other good resources to go further
into details, if the book isn't the right place for it.

After my completion of the Byte-Code VM in Zig, I wanted to challenge myself and
check if I really got the concepts the book supposedly teached me. For that I
sat out to make another implementation of `Lox`, which is also a Byte-Code VM in
Zig, but acts more in a Java VM kind of style, as in the `Lox`-Code gets turned
into the Byte-Code, which is put into a separate file, which then can be
executed by the VM. Just like Java programs get compiled into `.jar` files,
which are loaded and executed by the JVM. I also wanted to combine the two
concepts of Syntax-Tree and Byte-Code VM. So I first parse the Code into a
Syntax-Tree, analyze it for variables, constants etc. and then pass it into the
compiler, which emits the Byte-Code. The Syntax-Tree step got skipped in the book,
in which the Code gets directly turned into the Byte-Code by a [Pratt Parser](https://craftinginterpreters.com/compiling-expressions.html#a-pratt-parser).
I won't get into detail on how this works, as I don't use this technique myself,
but Nystrom also has [Blog Article](https://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/)
dedicated to Pratt Parsing.

I actually got it to work and was incredibly proud of achieving my own Parser,
Compiler AND VM. To be fair, a lot of it was still very much based on the book,
but I was proud nonetheless and learned a lot on how compilers and interpreters
work behind the scenes. I also used Reference-Counting for Garbage Collection
instead of the Mark-And-Sweep Algorithm used in the book.

## Now what?

I was at a point, where I was pretty confident in my abilities to build a
Tree-walking Interpreter, as well as knew the concepts of a Byte-Code VM. I
wanted to build my own language now! But how?

Well, I didn't want to build a language just for the sake of, which would have
been fun, but kind of pointless. I wanted to either make a domain specific
language, which solves some kind of specific problem, or bring in some other new
concept, that I hadn't done before. But I couldn't find something that fit
either so my little project had to be put on hold.

One day, at work, I asked one of the senior devs about how the Event-Loop in
Javascript works. I had an idea, but I was not _quite_ getting it yet. He told
me to watch a specific [Youtube Video](https://www.youtube.com/watch?v=eiC58R16hb8),
which explained and visualized the Event Loop in a fantastic way. Seriously, if
you are curious about JS and how it works in the Browser, watch that video.
Anyways, after I watched and understood that, I somehow got interested in how Go
does it's concurrency. I haven't done anything in Go myself, but I have a friend
who loves it and I only heard good stuff about it. I also knew, that it somehow
made an amazing concurrency model. So I put on my little detective hat and
started reading a bit into how Go works. It didn't need to dive too deep into
the rabbit hole to find answers and the concepts and techniques it uses are
actually quite simple. And that's where my spark for writing my own language got
reignited.

## Flowlang: Go inspired

Shortly after I started thinking about how I want my language to look like. I
wanted it to use Go's concurrency model but with a syntax that I am used to. I
quickly set some more specific goals for the language which concluded to:

- Coroutine Model, similar to Go
- Garbage collected
- Type-Safety
- Compiling to a single Executable, containing both the Byte-Code and the VM,
  also similar to Go

I had some more ideas and goals, but they are further in the future, if I want
to keep building up the language.

I asked ChatGPT for some ideas on how I could name this language and one of them
was `Flow`. I liked it, nice and short, so I took it. And with that, `Flowlang`
was born.

I first made some more notes on how the language should look. I searched for an
editor for writing grammars and found [this](https://bnfplayground.pauliankline.com/)
amazing tool. With it, I wrote the complete grammar for `Flowlang` and could
easily save it as a simple link into the `README.md`. After that I started with
the Compiler-Frontend. First Scanning, which turns the input string (aka the
source code of a `.flow` file) into a stream of tokens. These Tokens are then
turned into an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) by the
Parser. The Parser is also a more-or-less direct translation of the grammar,
which is why I made the grammar first. Parsing became a walk in the park after
that. Thirdly, the AST gets passed into Semantic Analysis, which scans the tree
and finds out stuff like "does this code make sense?" and "can this even work?".
In more concrete terms, Semantic Analysis checks for variables that are
accessible, if the different types are used correctly and so on. Pretty normal
compile-time checking stuff. Lastly, the scanned AST is passed into the
compiling part of the compiler. This is the part, where the high level syntax
nodes of the tree get translated into nice, low-level byte-code.

Now we need a Runtime for the Byte-Code. The end goal was to embed the byte-code
into the runtime to make a single executable containing and running both.
Leveraging Zig's Build System, this process is (in my humble opinion) incredibly
easy and elegantly solveable. I split the Source Code of Flow into Compiler and
Runtime. Each of them has their own entrypoint and marks their own executable.
Inside the Build System, I first compile the Flow-Compiler to then run it
immediately after with the `.flow`-file as input. The resulting byte-code file
is just temporarily saved and managed by Zig. Then, I use the `@embedFile`
builtin function of Zig to include the just compiled byte-code directly into the
runtime. Now I don't have any file reading and loading business to do at startup
and just the byte-code as if it is hardcoded into the VM. With that in place, I
just let Zig do it's thing and compile the runtime into the final executable.
This whole process sounds complicated, but has a few fantastic properties:

- I don't have to support any platform myself, because Zig's Cross-Compiling is
  just _that_ good
- I can assume that the embedded byte-code is completely checked and as correct
  as my compiler says it is because the Zig compiler only executes the runtime
  step if the previous steps succeeded
- The Zig Build System is so flexible, that with a little bit of knowledge about
  it, you could easily have preprocessing steps like linting, different build
  definitions for target platforms or release modes and so on

Another huge point about using Zig as a build system is extensability. One
feature I have planned, but is not yet implemented, is VM-Extension. These could
be just `.zig` files, which can be plugged into the Build System to extend the
built in functions. This enables me to offload building a great standard library
into different modules, that can be enabled and disabled based on project
requirements. This also means, the VM itself does not need to implement any
library functions at all, and just reads in definitions by the extensions. I
haven't thought about this feature enough just yet, but when the basics of
Flowlang are there and I start implementing some basic library type functions, I
will look into it more.

## When release?

I don't know. Currently, the project is still very much in development. At the
time of writing, it is barely an implemented language. You can do basic math,
print out the result and do negations on booleans (also the print keyword will
be removed as soon as there is a way to call builtin functions. For now, I just
need _some_ way of printing).

Starting now, I will try to update the devlog more regularly with Updates on
Flowlang. So if you are interested, check in a few times. Maybe there are
smaller news that are too little for whole blog post.

If you _really_ want to try it out, you can. You only need a current version of
the Zig nightly compiler. I am a sucker for new features and improvements,
that's why I'm following Zig master.

Oh, the repository, right. Almost forgot. Here's the link to [Flowlang's Gitlab Repository](https://gitlab.com/flowlang/flowlang).
