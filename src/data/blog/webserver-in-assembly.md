---
title: Writing a Webserver in ARM64 Assembly
pubDatetime: 2025-07-31T15:00:00
featured: true
tags:
  - ARM64
  - programming
  - assembly
  - low-level
description:
  I made a Webserver in ARM64 Assembly. This was incredibly interesting but also
  incredibly hard, what you can kinda expect when using assembly.
---

## Why?

Incredible Question. No Idea. Probably because I just like suffering and somehow
I _really_ wanted to try my hands at writing Assembly.

## What exactly?

This Webserver is very simple (duh, I'm not gonna rewrite NGINX in Assembly). It
is ably to serve very simple files from the path it got out of the URL. It
calculates the Content-Length correctly to set the header and not make the
browser/curl stay in a limbo-state. It has a simple CLI Interface to set the
docroot folder. It even has `--help` and `--version` options.

It crashes on a 404 and other errors. Basically it is only able to work with the
happy case. BUT, that actually works.

## Notable Stuff?

I used no dependencies, my help/documentation basically consisted of a few, VERY
sparse blog posts, the official documentation on the ARM Instruction Set, an
apparently non-stable list of System Call numbers in the Darwin Kernel and
literal manpages for the syscalls. After I kinda understood how the calling
convention works, I literally just looked at manpages locally to find out the
parameters and return values and got the rest down by trial and a lot of error.

I also built my own preprocessing to have a little better experience (if thats
even possible in Assembly). I did this in Zig. I created a `build.zig` even
before because that was the easiest way for me to have a simple-to-use build
system and assembler, which can also directly run the code. It contains a
hardcoded list of all Assembly source files, adds them to the executable and
builds it. The preprocessing consists of two Zig programs, that transform the
actual source files, puts the output into Zigs Cache and those outputs are
actually the files that get assembled at the end. The first step is a simple
constants replacer, so I don't have to remember the different numeric values for
different contexts and can simply type `SYS_WRITE` instead of `4` with add a
comment for explanation. The other step is pretty much the same, but with
character literals, so I can write `'/'` instead of the ASCII value of `/`.
These 2 Steps are very simple but surprisingly big improvements. Don't get me
wrong, there are still almost more comments than code to explain what I'm doing,
but at least I can keep them to a pretty high level explanation of what I'm
doing and not potentially lying to me on the detail of what this number `4`
means.

## Those are a lot of words

Because this is like pretty much as low-level as it gets, I may need to explain
quite a few words for my readers coming from the astronomically high-level Web
Development world.

(Also you can tell your boss you read this post for educational purposes)

This is an unsorted list of buzzwords that I already used in this post, or will
use later:

- **Assembly**: a "human-readable" version of machine code (not _quite_ a one-one but almost)
- **Assembler**: The program that turns _Assembly_ code to _Machine_ code
- **ARM**: CPU Architecture, mostly used in smaller devices like phones or embedded, but lately in Apples Desktops as well in the form of M-Series CPUs. The most common other Architecture for Desktop PCs is `x86` from Intel.
- **Instruction Set**: A CPU needs instructions that tell it what to do. These are defined per CPU-type in the Instruction Set. Basically a Lexikon of Instructions that this CPU understands
- **System Call/syscall**: The interface between "normal" programs and the OS-Kernel. Almost exclusively written in C, functions that are callable via a specific `syscall` instruction (which is `svc` in ARM64)
- **syscall number**: basically the function name of the syscall
- **Darwin**: The actual OS/Kernel that macOS is based on, which in turn is based on FreeBSD
- **Calling Convention**: Calling a function in Assembly works basically with a goto. To pass parameters and get the return value, the caller and callee must respect the same calling convention, aka use the same CPU Registers for the same purpose. _Important_: Calling Convention is OS-dependant, not machine code dependant
- **ABI**: **A**pplication **B**inary **I**nterface, pretty much the same as the calling convention, with some more stuff defined on top of it. Just like Calling Convention, it is defined by the OS, not the Machine Code.
- **Preprocesser**: Literally Text-Processing before the actual compilation/assembling
- **Register**: A Register as a place in the CPU that can hold some generic value. In ARM64, each register has 2 versions, 32 and 64 bit length. They are addressed using either `w1` or `x1` respectively. Both version address the same register, they just use a different amount of bits. There also specialised registers for floating point arithmetic for example and other specialised hardware.

## How can _I_ do that?

You Don't.

## How can I _really_ do that? For learning? _Please_?

_Sigh_. Okay, fine.

I will not show you how to do a whole webserver, that's a bit much for this
blogpost. I will however show you how to a simple hello world. That is enough in
Assembly already.

First, you need to decide what _kind_ of Assembly you want to program. For that
you have to decide these things:

- Target CPU Architecture
- Target Operating System
- Assembly Syntax dialect

If you want to follow exactly what I did, the answers to those things are:

- ARM64
- macOS / Darwin
- this is only important on x86. ARM64 only has one syntax, but x86 has for example the `AT&T` syntax and `Intel` syntax and even some more

Next up, you need to decide on the _Assembler_ to use. I used the Zig Compiler,
which in the background uses LLVM (at the time of writing). I used this because
that means I can use the Zig build system instead of a Makefile for example and
easily split up the Assembly into different files. For the purpose of this blog
post, I will just give you the `build.zig`:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .link_libc = false,
        .name = "myBinary",
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    exe.addAssemblyFile(b.path("src/main.s"));
    b.installArtifact(exe);
}
```

After this, at any point you can run `zig build` to compile and assemble your
program, after which you can execute it with `./zig-out/bin/myBinary`.

Now you can create the `src` directory and put your Assembly into `src/main.s`.

To make the Assembly actually executable, you need to provide a main function
aka the entrypoint. This is done via a label called `_main`. This changes
depending on the choices you made about the CPU Architecture or OS. Ultimately
this would depend on the linker but I will skip that part for now. Just
remember, if you can follow along with `_main`, great, if not try `_start` and
if that also doesn't work, you need to google for your own case. So, if you use
the same setup as I do, you should start by simply putting this into `src/main.s`:

```asm
_main:
    # some asm code
```

This creates a label called `_main`. This is not enough tho. We also need to
make this label be linkable/available from outside this file to be called. In
other words, we need to make `_main` a global. This is done by the `.global`
instruction. This goes at the top of the file like this:

```asm
.global _main

_main:
    # some asm code
```

Great, we have an assembly file that does nothing and even that crashes.

The simplest program is one that just exits immediately. To gracefully exit a
program, you must call the `exit` syscall. To find out how this function looks
like, you can try looking at the manpages (If you are on a UNIX based system
that is, so macOS, Linux or BSD). The syscall pages are generally defined in the
second page, so called `man 2 <syscall>` in a Terminal should open a nice
explanation of the syscall together with the function signature. In this
specific case, try running `man 2 _exit`. The underscore is not on every
syscall, so just try a little bit around when looking for a specific one.

Anyways, the entry for `man 2 _exit` shows us something like this:

```
NAME
     _exit – terminate the calling process

SYNOPSIS
     #include <unistd.h>

     void
     _exit(int status);

DESCRIPTION
    ...

RETURN VALUE
     _exit() can never return.
```

This is the output on my machine at least and should look rather similar if you
also have a mac. I left out the Description and some meta information. This is
left as an exercise for the reader to find out some details about this syscall.

We are interested in the function signature. It looks like this:

```c
void _exit(int status);
```

This means, to exit our program, we need to call the `_exit` syscall with the
appropriate status code as a parameter. This brings up a few more questions:

- How do we call this syscall?
- How do we call _any_ syscall?
- How do we pass a parameter?

To find out all of this, we can again look at the manpages. This time, try
running `man 2 syscall` (At the time of writing, this entry is missing on my
machine. Alternatively, you can view them online [here](https://man.freebsd.org/cgi/man.cgi?query=syscall&sektion=2&manpath=Debian+9.13.0)).

After reading a bit, we notice two tables. The first shows how to actually start
the syscall on different architectures with the corresponding asm instruction,
the second shows the parameter placement aka calling convention. In my case, I
look at the lines for `arm64`. Please note that Darwin has some differences to
other Operating Systems, namely the number after `svc` is not `0` but `0x80` and
the syscall number goes into register `x16` instead of `x8`. That being said, to
call a System Call, we need to do two things:

1. put the correct syscall number into the register
1. call the syscall instruction

In the case of calling `exit`, this looks like the following:

```asm
mov x16, ???
svc 0x80
```

Now you might ask, which number goes into the register? That is a very good
question. To find out, we can either try to look them up in the internet or we
look at the C header file where they are defined. The later can most likely be
found in `/usr/include/sys/syscall.h`, or in my case on macOS in `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/syscall.h`.
There all the defines starting with `SYS_` correspond to the syscall and define
the syscall number. We can see that `SYS_EXIT` has the number `1`, therefore we
need do enter `1` into the syscall number register:

```asm
mov x16, 1
svc 0x80
```

Now we have a complete and finally functioning executable. Try running it by
first compiling with `zig build` and then running with `./zig-out/bin/myBinary`.
This should not crash. To find out which exit code it got, try `echo $?`. This
prints the exit code of the last command before it. But how can we change the
code?

For that we need to pass a parameter. To do that, we already know everything. We
look at the calling convention into which register the first parameter is set,
in this case `x0` and set the number we want there, for example `0` for a
successful exit. The full file looks like this:

```asm
.global _main

_main:
    mov x0, 0
    mov x16, 1
    svc 0x80
```

This is the minimum needed to make a program compilable and executable without
crashing.

## Whats with the Hello World you promised me?

Actually there is not much more to it. Well, there kinda is, but nothing that
would make sense to explain in this blog post. There are enough resources on the
internet to do that and I tried asking an LLM to build me a Hello World in ARM64
Assembly on Darwin and it actually gave me the correct answer. It really is not
_that_ complicated once you got kinda comfortable with Assembly and raw CPU
Register juggling. Therefore you can try and build on top of what you now know
to make a real hello world program. Some words to hint you into the right
direction:

- How is a string represented?
- How does writing to StdOut _actually_ work? (Spoiler: Files)
- What syscalls do I need?

That should give you a direction from where you can build up your own Hello
World in Assembly.

## Again, Why?

This year, I got really into learning how computers work. That included
Low-Level programming with Zig or C but also trying my hands on an Assembly
project to find out what the CPU actually does and needs and what a Compiler
produces. I not only learned about Assembly and how the CPU works but also a lot
on how to read official documentation, how to get to my goal with minimal help
and resources and also how to debug with a Terminal based debugger. The latter
will probably be useless for me, as I tend to do print-based debugging but
still, valuable knowledge and experience.

## What if I want to look at the code?

Here it is: [View at your own risk](https://git.nkoll.de/nk/raw-http).
