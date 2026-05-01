---
title: Flowlang Pt.2 - Integration Testing
pubDatetime: 2024-12-08T16:00:00
tags:
  - flowlang
  - zig
  - interpreter
  - compiler
  - testing
description: I added Integration Tests to Flowlang to ensure correctness of the
  implementation and work against regressions when adding new features.
---

## Why testing a language?

Short answer: mistakes happen.

Long answer: because building a language is complicated and testing ensures
there are no regressions

While building [Flowlang](https://gitlab.com/flowlang/flowlang) I noticed that
testing is actually useful. Normally, I am a programmer who is not too big on
the side of unit testing for the sake of unit testing. But this project showed
me from time to time what happens if I do not test everything.

Luckily, and here speaks the Zig fanboy again, Zig is an amazing language and
gives you a complete unit-testing framework baked into the language itself. This
means, you can put your tests right next to the code it is testing, and easily
make changes both the actual code and the test cases as the project evolves.
It also has some self-documenting aspect, as you can jump to the source of a
specific function, look for the corresponding test and see an example usage
right there. This is how the standard library in Zig works and has helped me
quite a few times to understand how to use some parts of it.

Also, once Flowlang was getting more features, namely functions, I noticed that
it caused some regressions with variables and scoping. And I, stupidly, stopped
writing tests, as soon as I could actually just run the code. This meant quite a
bit of debugging and comparing the compiled byte code with my expectations,
tracing the stack of the VM and other things. Quite an effort, just to find out
I removed a line that actually compiled variable declarations.

## How to test a language?

I found for myself two different approaches: Unit Testing and Integration
Testing. "Integration Testing" may be the wrong word for what I will be
describing but that's the most fitting I could think of, it is already an
established word in the Software Testing space and it just sounds fancy.

The best experience you get is combining them. They serve different purposes, so
they should be used for different kind of things. Let's take a look at how I
used these approaches.

### Unit Tests

As I already teased above, Zig provides a great unit testing experience
out-of-the-box. While it may not be the most complete framework for Unit Testing
it provides pretty much everything you need for basic unit testing, like
assertions (which are made using the `std.testing.expect*` functions) and special
allocators for testing. This in combination with the close proximity to the
tested code makes unit testing your source code fairly easy.

In Flowlang I mainly used Unit Tests to test all the Compiler functionality
before I hooked up the whole Pipeline around it. I haven't yet had a way to
actually read in files, look at the compiled bytecode or even run the code so I
used Unit Tests to rapidly get the foundation of Scanning, Parsing and some
Compiling done, before I worked on the VM and hooking everything up. Also, I
ensured that everything I made so far would actually compile. Zig has extremely
lazy compilation, which means that code, that is not reachable through your
entrypoint or test cases is not even analysed by the compiler. This can cause
some errors to be hidden until you use the code and get bombarded by hundreds of
type errors you just didn't notice before. Unit Tests provide one way of forcing
the compiler to analyze those parts, even if your `main` function still is just
a `Hello World` message.

### Integration Tests

I told you about the regression in variables and scoping after I added
functions, right? That prompted me to implement some kind of Integration testing
or End-2-End Testing or similar, to make sure, my language actually behaves the
way I expect it to behave. This not only checks if my Zig code compiles, but
also if the final behaviour of the VM is exactly what I would want it to be. In
other words, I check the parsing, compiling, loading and executing of the
Flowlang System as a blackbox. I write some Flow code, make it print stuff, and
then check if the printed text is the same as I expect.

And this is where it gets interesting.

To get this to work, I had to do quite a lot of things. I have to read a file
containing a test case, which currently looks like this:

```
print("Some Flowcode");

=====

Some Flowcode
```

I have a marker (`=====`) to split the file into two halfs. First the flow code
to test, second the expected output of `StdOut`. That way I don't have to jump
between multiple files and keep the expected output right next to the tested
code.

After reading and splitting those files, the Flow source code must be put in a
separate file, because my compiler expects it to be file. Then I have to invoke
the compiler, tell it where this (temporary) input file resides and where the
byte-code output should go. After that, I take the byte-code, which is again
written to a file, and embed it into the runtime. This runtime-bytecode-bundle
gets compiled as the final resulting binary. This binary then gets executed, the
Console Output (namely `StdOut`) gets captured and compared to the expected
result.

Sounds like a lot of steps, but not to difficult, right? Well, to actually
compile and run those steps, I have to invoke the Zig build system. Also, sounds
simple enough, I mean, all those things already are possible on the command
line, so what's the problem? Well, the unit-tests have their own step inside
`build.zig`, so I can just run `zig build unit-test` and it executes the unit
tests. I wanted to have the same comfort for the integration tests. So I am
already inside the Zig building process and now I want to invoke it again, for
each test case? I don't think that's quite as easy.

Fortunately, it's possible. Even better, I have another thing I can brag about
and try to convince people to use Zig. Whats possible with the Build system is
incredible! Basically, the `build.zig` is not actually compiling anything. It's
only responsibility is to build up the dependency/compilation graph of the
things that _should_ be compiled. This tells the Zig compiler what to do. Using
this knowledge, and some nice functions inside the standard library, I now build
up the dependency graph for integration tests. That means, I iterate over every
test case and create six steps for the compiler to run:

1. Compile the (Flow-)Compiler
2. Write the Flow Code to a temporary file
3. Run the Flow-Compiler with that temp-file
4. Compile the Runtime including the byte-code
5. Run the runtime and capture StdOut into a File
6. Compare the output to the expected string

To my luck, I found out that Zig has a `CheckFile` step already builtin. This
takes the expected string and a so-called `LazyPath`, which is just a build-time
path to a file, thats generated by the compilation process. If the contents of
the file and the expected string match, this step succeeds, otherwise it fails
with a nice error message saying what string was expected and what text it got.

## Running the tests

With all that in place, I can enter `zig build integration-test` into my
terminal and it just works™. It runs through all my integration tests, runs them
and tells me if they fail, and why. Adding `--summary all` shows me the complete
graph of the compilation process. At the time of writing, it looks like this:

![](@/assets/images/flowlang/integration_testing-dep_graph.webp)

As you can see, next to most of them it says "cached". The Build System has an
impressive caching system in place, as it only recompiles things, that have
changed. In other words, even if I have no cache yet, it would only compile my
Flow-Compiler once, for all tests. Every subsequent run would also only
re-compile and run the tests that changed, or all of them, if my
Compiler/Runtime code changed. This has the added benefit of being super fast
when iterating.

Oh, and the failing tests look like this:

![](@/assets/images/flowlang/integration_testing-failing_test.webp)

## Conclusion

Writing unit tests in Zig is already easy and possible using only the Zig
compiler. But other types of tests require more work. That being said, they are
still relatively easy using built-in functionality and are able to leverage the
Zig Build System in an efficient manner.
