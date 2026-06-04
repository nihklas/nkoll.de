---
title: Flowlang Pt.4 - Garbage Collection
pubDatetime: 2025-07-22
featured: true
tags:
  - flowlang
  - zig
  - interpreter
  - compiler
description:
  I added working garbage collection to my own Programming language. It uses a
  Mark-And-Sweep strategy and leverages Zigs Allocator interface for seemless
  integration into the existing functionality.
---

## What is Garbage Collection?

Garbage Collection is one way to manage memory in a programming language. There
are languages that have Garbage Collection and there are language that don't. To
cite the definition from [Wikipedia](<https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)>):

> In computer science, garbage collection (GC) is a form of automatic memory
> management. The garbage collector attempts to reclaim memory that was
> allocated by the program, but is no longer referenced.

In other words, your program most likely needs memory. To get memory it needs to
allocate it. At some point the program is done with a portion of memory and will
never access it again. At that point, that region of memory is called garbage.
The Garbage Collectors job is to find those regions of unused memory and free
it, to be available in other programs or even by the same program again.

This is in stark contrast to most lower-level language like C and friends, where
you, the programmer, need to manage that memory yourself. To do anything
meaningful, you need to manually allocate memory, and later in the program
manually free the memory when you no longer use it.

Memory is a finite resource. To ensure performant and efficient programs, there
has to be _some_ way to manage it. Garbage Collection is one of those ways, used
by most high level languages like Java, PHP, JavaScript, Go, Ruby, basically any
language where you don't have to manually say "Hey OS, give me some memory,
please?".

## Why would you want a GC?

Garbage Collection sounds good enough, it takes on the burden of reclaiming
unused memory and manages it for us. But that, as all things in life, comes at a
cost. A performance cost that is.

Garbage Collection in its simplest form at some point has to tell the runtime to
completely stop in order to accurately collect the garbage. If that isn't the
case, there might be edge cases where the program tries to allocate memory, and
the garbage collector tries to free it immediately, because it kicked in at
precisely the moment between allocation and usage. Because every piece of
memory, that isn't directly used, is marked as garbage. These bugs are also
notoriously difficult to debug, because garbage collectors are a
non-deterministic system. This is because when they kick in is a factor of how
much memory the program uses, how much is available and other tunable factors.
The combination of all of these makes garbage collection quite unpredictable.
Also, the fact that the memory allocated has to be tracked at all causes the
usage of garbage collection to be a performance hit. Every allocation now needs
to have some metadata associated with it, or in other implementations, the
garbage collector needs to track those itself. In any way, there has to be some
list or collection that has information about all memory allocated and what is
in use.

Even though all of this doesn't sound great, garbage collection is still an
important tool to have in a programming language. Some things just need memory,
so imagine programming an enterprise level software in something like Java and
also needing to worry about where and how long your objects are used. That
mental burden is something we don't want to have in higher level languages.
There use cases, for example performance critical programs, where the overhead
of a garbage collector is to great and manual memory management is needed.

In the case of Flowlang I chose to implement a garbage collector because the
language is supposed to be quite high level, and the user should not worry about
memory. Also, this language is not designed for performance critical
applications, so the overhead on the runtime is a fair trade-off compared to the
easier language.

## How does a GC work?

There are many different strategies to implement a garbage collector. Some
examples are:

- Reference Counting
- Mark-And-Sweep GC
- Generational GC
- Copying GC

The simplest, which I also implemented in Flowlang, is the Mark-And-Sweep-GC. It
does basically what the name says, it first marks every memory region still
reachable in some way or another, and then sweeps everything else. This works by
having an internal structure that keeps track of all allocations made, which is
why they are also sometimes called "Tracing GC".

To implement this in Zig, I chose to implement it using the Allocator interface.
Zig provides a common, vtable-based, interface for all Allocators. You can build
your own Allocator by providing a function that returns an instance of this
generic Allocator interface. In practice, it looks like this:

```zig
pub fn allocator(self: *GC) Allocator {
    return .{
        .ptr = self,
        .vtable = &self.vtable,
    };
}
```

The vtable consists of (at the time of writing) 4 generic functions that need to
be implemented by the Allocator Implementation:

```zig
.vtable = .{
    .alloc = alloc,
    .resize = resize,
    .remap = remap,
    .free = free,
},
```

These are the "primitives" that an Allocator works with. My GC has a backing
allocator called "child_alloc", that gets passed from the outside. This way, I
wrap the inner Allocator with the GC-logic. I can then choose to use the faster
`smp_allocator` for optimized builds and the `DebugAllocator` for safe and debug
builds to check for memory leaks.

The actual implementation of those allocator primitives is pretty simple, just a
wrapper call around the inner allocator plus some bookkeeping for the GC to
actually work. For demonstration purposes, here is the `alloc` function:

```zig
pub fn alloc(ctx: *anyopaque, len: usize, ptr_align: Alignment, ret_addr: usize) ?[*]u8 {
    const self: *GC = @ptrCast(@alignCast(ctx));

    self.gc();

    const bytes = self.child_alloc.rawAlloc(len, ptr_align, ret_addr);
    if (bytes) |alloced_bytes| {
        if (len == 0) {
            return bytes;
        }

        self.managed_objects.put(self.child_alloc, @intFromPtr(alloced_bytes), .{ .alignment = ptr_align, .len = len, .alive = true }) catch {
            self.child_alloc.free(alloced_bytes[0..len]);
            return null;
        };
        self.bytes_allocated += len;
    }
    return bytes;
}
```

Except the line `self.gc()`, this looks pretty easy. After allocating some bytes
with the inner allocator, given it was successfull and actually more than 0
bytes, I put the memory into the `managed_objects` map, that just maps a memory
address (coming from `@intFromPtr` to use the address as an integer) and a small
struct for some metadata. I also set it to alive on creation because I assume it
to be used immediately.

The other functions look similar, thin wrapper around the `child_alloc` plus
some bookkeeping.

The interesting part is inside the `gc()` function:

```zig
fn gc(self: *GC) void {
    if (!self.enabled) return;

    if (stress_gc or self.bytes_allocated >= self.next_gc) {
        self.mark();
        self.sweep();

        self.next_gc = self.bytes_allocated * gc_growth_factor;
        if (self.bytes_allocated == 0) {
            self.next_gc = initial_gc_theshold;
        }
    }
}
```

This looks simple enough, right? If the GC is enabled, and a specific threshold
is reached, it marks then sweeps and updates the thresholds depending on the
left memory.

Sweeping is easier, so let's take a look at that first:

```zig
fn sweep(self: *GC) void {
    var iter = self.managed_objects.iterator();
    while (iter.next()) |entry| {
        const obj = entry.value_ptr;
        if (obj.alive) {
            obj.alive = false;
            continue;
        }

        const buf = @as([*]u8, @ptrFromInt(entry.key_ptr.*));
        self.allocator().rawFree(buf[0..obj.len], obj.alignment, @returnAddress());
    }
}
```

We iterate over all known memory and check if it's alive. If it is, we leave it
and set it to unalive for the next GC round. Marking something as alive is the
responsibility of the `mark()` function. If something is not markes as alive, it
is freed by the GC's allocator function, which in turn removes it from the
`managed_objects` list and actually releases the underlying memory.

Now that we got that out of the way, let's look at marking:

```zig
fn mark(self: *GC) void {
    for (self.vm.globals[0..self.vm.globals_count]) |global| {
        self.markFlowValue(global);
    }
    for (self.vm.value_stack.stack[0..self.vm.value_stack.stack_top]) |value| {
        self.markFlowValue(value.deref());
    }
}
fn markFlowValue(self: *GC, value: FlowValue) void {
    switch (value) {
        .null, .bool, .int, .float => return,
        .function => return,
        .builtin_fn => return,
        .string => |str| {
            if (self.managed_objects.getPtr(@intFromPtr(str.ptr))) |obj| {
                obj.alive = true;
            }
        },
        .array => |arr| {
            if (self.managed_objects.getPtr(@intFromPtr(arr))) |obj| {
                obj.alive = true;
            }
            if (self.managed_objects.getPtr(@intFromPtr(arr.items))) |mem| {
                mem.alive = true;
            }
        },
    }
}
```

These two functions are the most important step in the garbage collection
process. They mark everything reachable through the current state of the virtual
machine, aka the runtime, as alive. If they miss something, we get a potential
use-after-free bug. On initializing of the GC, I pass in a reference to the VM.
That way, the GC has access to the internals of its state and can see what the
VM can see. It then simply iterates through all globals and the complete stack
at that point in time and marks those entries as alive. In the function
`markFlowValue()` we can see that only some values are actually needed to be
GC'd, mainly strings and arrays. All other types (so far) are placed on the
stack so to create those, there is no memory allocation involved. If I add new
types to the language, that need to live on the heap, I have to add them here so
that they can correctly be garbage collected when no longer in use.

## How to use this GC?

On initialization of the VM, it gets passed the Allocator of the GC as the
generic Allocator interface, together with a nother Allocator for general
purpose that is not garbace collected (for example allocating space for the VMs
stack):

```zig
pub fn init(gpa: Allocator, gc: Allocator, code: []const u8) VM {
    return .{
        .gpa = gpa,
        .gc = gc,
        // ...
    };
}
```

Then, everytime a FlowValue is created, that needs to be GC'd, instead of using
the `gpa`, we simply use `gc`:

```zig
// ...
const items = self.gc.alloc(FlowValue, capacity) catch oom();
const arr = self.gc.create(FlowArray) catch oom();
// ...
```

This is great, because we can simply switch out the GC implementation to a
totally different allocator with a different strategy, as long as it can work
solely through the allocator interface. This would include for example
Generational GC. So when I decide to try out a different GC implementation, I
simply switch out the passed GC and it should just work©. This also makes the
whole implementation of the VM simpler because I can use Zigs standard library
for my own heap objects as well, just by passing in the GC instead of a
different allocator. I also don't have to write wrapper functions or custom
implementations just to use a garbage collector. One example is the string
conversion/formatting of FlowValues:

```zig
fn concat(self: *VM) void {
    const rhs = self.pop();
    const lhs = self.pop();

    const result = std.fmt.allocPrint(self.gc, "{}{}", .{ lhs, rhs }) catch oom();
    self.pushValue(.{ .string = result });
}
```

Without going into detail on how the format works, because I create a new
string, it needs to be created on the heap. Also, because I will use this value
later in Flowlang Userland, I use the `gc` allocator, so that it can be tracked
and later freed when it is no longer on the stack or stored in a variable or
similar. I did not need to make my own formatting function for that, I simply
use the existing functionality that Zig provides out of the box.

## Let's wrap things up

I can proudly say that I implemented this GC from the ground up myself and it
works pretty well. When running the VM in a safe mode, no leaks are detected.
The performance is not yet tested but I plan on doing it in the future to
possibly optimize it or even switching it out to a different, more efficient
strategy. I also added a compile-time option to stress-test the GC, meaning it
will try to collect garbage on every single allocation, not just when the
threshold is met. This way I can test for hard-to-find bugs involving garbage
collection, especially freeing something in the middle of an operation.

Flowlang is coming along very well, it is already in a usable state, so if you
want to try the language out for yourself, take a look at the [Repository](https://gitlab.com/flowlang/flowlang).
