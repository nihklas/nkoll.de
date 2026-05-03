---
title: Homepage rework
pubDatetime: 2026-05-03T18:00:00
tags:
  - astro
  - web
description: I got tired of my previous homepage and blog and decided to start fresh with AstroJs. I chose a template/theme and just went with it.
---

My previous homepage was a simple static HTML page with a bit CSS that I copied
from [bashbunni.dev](https://www.bashbunni.dev/) and customized a bit and a
teeny tiny bit of JS. This was more than enough for a simple homepage that just
says what I do and links to a few projects I am proud of.

After that stood I wanted to try blogging. Since I am very much into zig and
joined both the [zig](https://ziglang.org/community/) and
[sycl](https://softwareyoucan.love/) community on discord. On the latter I
followed the development of [zine](https://zine-ssg.io/) which is a
static-site-generator built in, you guessed it, zig. It also came with a custom
templating engine and markdown flavour, called SuperHTML and SuperMD
respectively. SuperHTML even comes with a full-blown HTML-LSP, that you can also
use in other projects. It is apparently the only LSP that _actually_ follows the
spec and reports errors in your document correctly. Anyways, since I am really
into zig, naturally I wanted to use software that comes out of that community.
So I started working on my blog in zine. I integrated tailwindcss and copied
over the general CSS from the homepage so they look identical.

Working with zine did have a learning curve and some interesting decisions,
specifically in the templating, but nothing that you couldn't get used to. The
bigger annoyance/problem with using zine was my personal workflow using nix.
To keep a long story short, building zine from source inside a nix sandbox is
somehow very difficult. Mainly because when it updates zig versions, but some
dependencies are not yet upgraded, you either have to wait or fork everything in
the dependency tree that isn't updated and update it yourself. This is obviously
too much work _just_ to use an SSG. Also, to make matters worse, there was a
`flake.nix` inside the zine repository. But since the maintainer didn't use nix
himself, this was a maintenance burden that only third party contributors would
look at and he (rightfully) decided to remove it from the project. This meant
that I couldn't include zine into my flake directly and would have to look at
another workaround/hack just to _build_ my blog. This was too much work and
stopped regularly writing.

## The new homepage

I somehow got interested in [Astro](https://astro.build/). Normally I am really
not a JS guy, but this looked like the best SSG I could use. It has support for
fully statically generated sites, it's own component system (so I don't need to
use something like React) and the option to integrate pretty much anything from
the JS world, even fullblown frontend frameworks like Angular or Vue.

I first tried migrating the homepage and redo the design in Astro using
tailwind. That did work but I also got tired of the design. So somewhere along
the way I decided to throw away my first attempts and start completely new,
again. I looked for themes to use since I didn't want to design it myself. I
just want to have a blog/homepage and write some content on it, I don't care
about the design anymore. I found [astro-paper](https://github.com/satnaing/astro-paper)
and liked it. So I started a new project with the template and after a bit of
configuration started migrating all my blog posts. This was a fast and easy
thing to do and in a few hours of work I completely migrated my blog. The
previous homepage is now gone and replaced by the blog directly. I moved the
information that I wanted to keep from the original page over to the "About Me"
page.

I also added back the auto-deployment I had for the previous blog, did some
repositosy organization and finished up the move to the new workflow.

## I want to write more

I haven't written a new blog post in a long time. I want to write more, as I
would like to think that there are people that would want to read what I got to
say. Also, this is a nice way to log my progress and maybe look back at this in
a few years and see where I started. Also also, I just really like to talk and
tell people about stuff I care about and the opinions I have and with a blog I
don't have to annoy people with that in person. Instead I annoy them to read
this.
