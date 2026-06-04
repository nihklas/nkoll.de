---
title: Flowlang Pt.3 - Standalone Compiler
pubDatetime: 2025-07-20
tags:
  - flowlang
  - zig
  - interpreter
  - compiler
description:
  The compile times got to slow for my liking, so I looked into a semi-correct way
  to make the compiler standalone. Now the compilation of flow code is blazingly
  fast© and you don't need to have the Zig compiler installed to use Flowlang.
---

## What does "standalone" mean?

Standalone, in this context, means that the flow-compiler can be used without
any third party compiling or building tool. In my case, this was the Zig
Compiler. Previously, you had to have the Zig compiler in order to program in
Flow. This was nice, from a language developer standpoint because the Zig build
system is incredibly powerful and the way I structured and built my bytecode
based VM and the whole compiling pipeline, I needed (and wanted) to use Zig for
that. This enabled me to both compile my Compiler, run it and then compile the
VM, which already has the Bytecode embedded. Now, to turn Flowlang into a
standalone compiler, I had to come up with something smart because I still
wanted to spit out real binary executables but I didn't want to include LLVM or
even build my own machine code compiler.

## The Problem

The basic Problem statement was this:

"How can I add my compiled Bytecode into an already existing binary file?"

This question arose from a quick realisation, that the previous compile workflow
needed to be reversed. Instead of embedding the Bytecode into the VM source and
compiling that as a whole, I needed to compile the VM first, and make the
Compiler retroactively add the Bytecode into the already compiled VM.

I first started with experiments using just the Zig Build System, but I quickly
stopped those explorations as I explicitely wanted to remove the dependency on
Zig for language users.

Next up I looked into something I call, for the lack of knowing the official
word, "Binary Patching". My inspiration was a talk I saw about Roc's "Surgical
Linker". You can watch it [here](https://www.youtube.com/watch?v=SS_lQAjBVtk).
This TL;DR of what I used from this talk was something along the lines of "You
can compile the whole application beforehand, and surgically add the Roc
Application into it". That sparked a curiosity that I needed to go after.

## Binary Patching

Roc call that process, or rather their tool for that process, "Surgical Linker".
I call it "Binary Patching". It basically means the same thing. Compile one
thing before, add another thing to the executable afterwards. To try out my idea
I travelled down a small rabbit hole about the ELF format. The above talk has a
section dedicated to the ELF format, so I knew roughly what to look for. That,
and with the help of ChatGPT, I quickly got a working proof-of-concept running,
that enabled me to "surgically" add a string into an already compiled binary.
The last working example can be seen [here](https://git.nkoll.de/nk/poc-binarypatching/src/commit/aa91706cca66dd392a0d8ea34acc0aeaad32b6c2).
This was a fun endeavor but already had 2 significant problems:

1. The space had to be reserved in the precompiled binary, so I had a hard limit
   on how many bytes I could add
2. So far, this was ELF-specific, in other words, linux-specific

These were big reason for me to disregard that strategy for now. Maybe I'll come
back to it in the future, if the current solution has drawbacks, that I have not
seen so far.

Which brings me to...

## The Solution

The solution came from a friendly user on the zig discord, where I discussed my
findings and other ideas with other zig programmers, most of which are way
smarter than me. There they said, I could simply append my string onto the end
of the executable and make the VM read "itself" on startup. How Genius!

I didn't know executable formats enable these sort of shenanigans (disclaimer: I
only tested it on Linux and MacOS. I have no idea if this works on Windows, but
I would assume it does). That meant I could embed the compiled VM into the
compiler, write the already compiled machine code to a file, append my bytecode
and voila, a self hosted compiler was born. The way it works is incredibly
simple and (at least I find it) elegant:

1. Compile the VM like you would normally
2. Embed the VMs machine code into the Compiler
3. Compiler writes this machine code into a file
4. Compiler appends the bytecode to that same file
5. Compiler appends the length of the bytecode as the last 8 bytes to the file
6. On startup, the VM "reads itself", jumps to the last 8 bytes for the length,
   jumps that many bytes backwards and now it has the complete bytecode
   available

Nothing here is particularly fancy or difficult. And because we use Zig, to
embed the VMs machine code into the Compiler, all we need is these lines in the
compiler and `build.zig`:

```zig
// compiler
const vm = @embedFile("runtime_bin");

// build.zig
compiler_mod.addAnonymousImport("runtime_bin", .{ .root_source_file = runtime.getEmittedBin() });
```

The line in `build.zig` looks a little complicated, but it basically says "make
this file available as a string literal under this name".

With that out of the way, the compilers final steps are now these:

```zig
// create final executable
const file = try std.fs.cwd().createFile("output", .{});
defer file.close();

// make file executable
try file.chmod(0o755);

// write VMs machine code (the actual executable)
try file.writeAll(vm);
// write the bytecode itself
try file.writeAll(code);

// get the length of the bytecode into 8 bytes and append it to the file
const bytecode_len: [8]u8 = @bitCast(code.len);
try file.writeAll(&bytecode_len);
```

That is all it takes to create a complete, runnable binary with Flowlang!

## Why is this useful?

My initial motivation was compile time speeds. The way that the code was
compiled before was very cool and fun, but it meant that the whole VM needed to
be recompiled by Zig everytime the Flowlang source changed. That is especially
annoying since Zig is not yet able to self host their compiler backend on ARM64,
aka M-Series Macs, which I primarily code on. That meant, not only was Zig
involved into the compilation process, but also LLVM. And _that_ was the big
performance hit. The compilation speed was also completely unchanged by how big
the Flowlang source was. Flowlang's compiler was pretty much instant in
comparison. So even for the simplest Hello World, the compile time was
horrendous.

With the new system in place, the compilation of Flowlang takes place completely
without the Zig compiler, and in turn without LLVM. That means compiling a
single Flowlang Source File now is a matter of milliseconds (That might change
in the future when an import system is added to the language and the projects
grow, but it'll still be orders of magnitude faster than the previous
compilation pipeline).

Another benefit I found out after I got it working was simple to distribute
binaries. As I specifically do everything in the core language myself and do not
rely on third-party libraries, neither zig nor c nor anything else, the final VM
and Compiler executables are completely static binaries. Users of Flowlang are
no longer required to install anything other than the Flowlang compiler itself,
and that is literally just a downloadable file.

## What can I do with all this information?

Except being fascinated there is probably not much all of this can do for you.
Unless you are working on something similar yourself, this is literally just for
me to nerd out about some cool stuff I found, but that is what the whole blog
site is about, right?
