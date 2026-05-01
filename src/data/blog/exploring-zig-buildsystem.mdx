---
title: Exploring the Zig Buildsystem
pubDatetime: 2024-10-29T18:00:00Z
tags:
    - zig
    - zig buildsystem
description: I made my own Command Line Parsing Library and used it as an excuse to explore the possibilities of comptime and the buildsystem.
--- 

The [Zig Buildsystem](https://ziglang.org/learn/build-system/) is an amazing
tool for managing Zig projects, as well as C/C++ based projects. I already used
it in [Japr](https://git.nkoll.de/nk/japr) as an alternative to CMake. It
made cross-compiling as easy as getting the sysroot from Docker Images and just
compiling. But it can do quite a bit more than just compiling your project.

## Introducting Zli

I wanted to make some console applications in Zig, so naturally at some point I
was in need of argument parsing. I looked around to find some existing
libraries, as well as hand-rolled the parsing logic in some projects already.
But the latter was to much work and none of the existing appealed to me. Maybe
because I wanted to make it myself anyways.

Here comes [Zli](https://git.nkoll.de/nk/zli), my own
Argument/Options-Parsing Library. Even though the others all have a valid place
and I am sure all have something great to offer, I built it to fit my own needs,
so naturally that is the library I will use for all my projects going forward.

It has basically all features you would expect:

- Positional Arguments
- Options in long form (`--some-option`)
- Short options (`-a -b`)
- Multiple short options (`-abc`)

Some more advanced features I am particularly proud of:

- Subcommands (`maincommand subcommand --some-option some-argument`)
- Enums as expected value
- Help-Text generation

My first approach consisted of some comptime-magic© which worked suprisingly
well for simple commands with some options and arguments. Building it also was a
lot of fun. Don't we all love our occasional Meta-Programming. This way I built
a Struct-Type at Compile-Time which got populated by `.parse(...)` and could
simply be used with field access. You just define your command structure in an
anonymous struct and could more-or-less use the same structure in the resulting
type, with the fields containing the actual parsed value instead of the
definition. You have compile-time type-checking, null-safety for options,
default-values, boolean flags were not-nullable and defaulted to false, and a
lot of more niceties I am still very proud of.

That was good and all, but when I started to look at how to implement
subcommands in that structure, things started to escalate a bit...

## Buildtime vs Comptime

Next step was to build the subcommand logic. In theory fairly easy:

1. Recursively go through subcommand definitions
2. Build options and arguments the same way as global
3. Profit

As the subtle foreshadowing implied, 'Profit' was in fact not reached.

Turns out, recursively building a Struct at comptime is far from easy. I tried
to make it work for like a week until I gave up and decided to look for a
different solution. I knew that the Buildsystem was capable of generating
Zig-Files at build-time and importing them into other Source Code Steps. I
figured that instead of building the Parser at Compile-Time, I could just build
it at Build-Time. I made a simple Prototype of the resulting Parser by hand,
tried it out and just wrapped it in a multiline string. This is written to a
file at build-time and imported by the main file. Lo and behold, it works! You
can even look at the implementation of the generated Parser! Its Code is also a
lot simpler and easier to understand than the comptime acrobatics I had before.
If you want, you can just copy the Parser File out of the `.zig-cache`
Directory, modify it and use that instead.

Generating the Code for this File was also not to difficult. The
'ParserGenerator'-Code is not pretty, but it works. And it also reads fairly
streamlined from top to bottom. It is not using any templating or anything, just
plain old string-building and writing to a file. If it's stupid and it works,
it's not stupid.

Back to topic. I started with rebuilding the same logic I had in the
Comptime-Parser. Once that was done, I had proven to myself, this approach works
and I had the confidence to pull through with it. That was already the third
rewrite of the whole library so I needed some kind of breakthrough moment to
keep going with my idea. The generated Parser was as specific as possible, with
the necessary sprinkles of abstraction, to make the parser generation itself
more fun and easier to work with. Stuff like type conversion has its own
function. 

Adding subcommands was now almost trivial, as the code runs normally and
recursion is simply a matter of writing stuff to a file. The active subcommand
is marked by a union field at the same level as the options and arguments. If it
is set to '`_non`' the parent command is active, otherwise the corresponding tag
to the command name is active. The type of the union members (expect `_non`) are
again structs with exactly the same structure as the top-level definition. So
accessing nested Subcommand looks like
`parser.subcommand.first.subcommand.second.option.@"some-option"`. This is ugly,
but only because one chooses to write it like this. The example code in the Zli
Repository looks something like this:

```zig
switch (parser.subcommand) {
    ._non => return baseCommand(&parser),
    .hello => return helloCommand(&parser, alloc),
    .@"with-minus" => {
        std.debug.print("It works!\n", .{});
        return 0;
    },
}
```

With each function looking something like: 

```zig
fn helloCommand(parser: *Zli, alloc: std.mem.Allocator) u8 {
    const hello_cmd = parser.subcommand.hello;
    switch (hello_cmd.subcommand) {
        ._non => {
            // ...
        },
        .loudly => |loud_cmd| {
            // ...
        },
    }
    // ...
}
```

This switching and function calling uses Zigs Syntax Features to differantiate
the subcommands. Looks much better and nicely communicates the different
intentions of the subcommands. Imagine a giant command like `docker` or `git`
with a lot of subcommands. Using a `switch(parser.subcommand){...}` makes their
implementation nice to read and nice to write. Of course, this would also be
possible with other methods but I wrote this Library with specifically this
Structure in mind. I also make use of other Zig language features.

## Zig is great

After reading this, it should come to noones surprise, that I love Zig. I won't
get into all the details I like about it, but I will show what I used to make
the usage of Zli as nice and natural as possible.

#### Anonymous Structs

Writing the Command Definition is as easy as passing an anonymous struct that
complies to some simple structure:

```zig
try zli.generateParser(.{
    .desc =
    \\This Command acts as an example on how to use the Zli library
    \\for command line parsing. Take a look at the files in ./example 
    \\to see how this example works.
    ,
    .options = .{
        .bool = .{ .type = bool, .short = 'b', .desc = "Just some random flag" },
        .str = .{
            .type = []const u8,
            .desc = "Put something to say here, it's a string, duh",
            .value_hint = "STRING",
            .default = "hallo",
        },
        .int = .{ .type = i32, .short = 'i', .desc = "If you have a number, put it here", .default = 0, .value_hint = "INT" },
        // ...
    },
    .arguments = .{
        .age = .{ .type = u8, .pos = 0, .desc = "Put in your age as the first argument", .value_hint = "INT" },
    },
    .subcommands = .{
        .hello = .{
            .desc = "Greet someone special",
            .arguments = .{
                // ...
            },
            .options = .{
                // ...
            },
            .subcommands = .{
                // ...
            },
        },
    },
});
```

Every field is optional. If you don't want/need a description, just don't write
one. If you don't have any arguments, don't include them in the definition.

At least for, this way of defining the structure feels natural. After all, I
designed this Library for me specifically. 

#### Types as Values

In the above example we can also see how to give the options the correct types.
Because in Zig, Types are just Values known at compile time we can pass them
around as we please. This allows the resulting Parser to have exactly the same
type as you specified, which in turn makes using them type safe. Do you want a
normal string (`[]const u8`) or a null-terminated (`[:0]const u8`)? Just change
the type definition in here. No need to learn a new type system, that hides them
behind enum values or mapping custom names to types.

#### Nullable Types

```zig
// For required arguments, this pattern leverages zigs 'orelse' keyword,
// to print the help text and exit with a correct return code
const age = parser.arguments.age orelse {
    std.debug.print("{s}", .{parser.help});
    return 64;
};
```

The help/usage text is generated at build-time, so the field is available even
when parsing failed. As all options and arguments are a nullable type by
default, you can easily check the existence of needed arguments using the
`orelse` keyword and give it fallback values or print the usage and exit, like I
do.

## Building the Parser

The Parser is generated at build-time, we know that by now (I can't seem to shut
up about it), but *how* is it generated at build-time? Let's take a look.

```zig
pub fn buildParser(b: *std.Build, zli_module: *std.Build.Module, program: *std.Build.Step.Compile, parser_file: []const u8) void {
    const generate_parser = b.addExecutable(.{
        .name = "generate_parser",
        .root_source_file = b.path(parser_file),
        .target = b.host,
    });

    const config = b.addOptions();
    config.addOption([]const u8, "program_name", program.name);

    zli_module.addOptions("config", config);
    generate_parser.root_module.addImport("zli", zli_module);
    const gen_step = b.addRunArtifact(generate_parser);

    program.root_module.addAnonymousImport("Zli", .{ .root_source_file = gen_step.addOutputFileArg("Parser.zig") });
}
```

That function is responsible of generating the Parser. That's it. Using it in
your own `build.zig` is as simple as calling it:

```zig
const zli = @import("zli");
// ...
const zli_dep = b.dependency("zli", .{});
// ...
zli.buildParser(b, zli_dep.module("zli"), exe, "src/cli.zig");
```

`"src/cli.zig"` is the path to the program entry file where the Parser
Definition is created. This ability to call almost arbitrary code in the
build-pipeline and creating source code files at build-time is amazing. I feel
like this shouldn't be that easy.

## Anyways

Sure, there are already other Libraries out there like this. And they all have
something to offer that i don't. But I made Zli myself, and I like it. So if
anyone wants to try it out, please feel free to do so. If you encounter any
issues, just open some... well... issues.
