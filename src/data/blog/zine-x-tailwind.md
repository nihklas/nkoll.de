---
title: Zine x Tailwind
pubDatetime: 2024-11-18
tags:
  - zine
  - tailwind
  - zig
  - web
description:
  Bringing Tailwind into Zine was as easy as installing Tailwinds CLI-Tool and telling the Build
  System to use it. It brought back some of the fun in writing CSS and made my life designing
  and building pretty Webpages a whole lot simpler.
---

> Disclaimer: Zine is now mainly used as a standalone CLI tool. To integrate
> tailwind into that workflow I would suggest to setup an additional filewatcher
> that compiles the tailwind into a css bundle that then is picked up by zine's
> devserver. It is still possible to use it from a `build.zig` workflow, but
> from what I can see in the community, this is not the default way anymore.

## Introducing Zine

I love [Zig](https://ziglang.org/). So naturally, I want to solve every problem using it. After all,
[it is always the correct choice](https://en.wikipedia.org/wiki/Law_of_the_instrument).

I also dislike the modern Web-Development trends and practices. Too much reliance on
[JS-Frameworks](https://react.dev/) for everything, unnecessarily complicated Websites and don't get
me started on [JavaScript on the Server](https://nodejs.org/en). But I'm going off course.

I do like the concept of SSGs ([Static-Site-Generators](https://en.wikipedia.org/wiki/Static_site_generator)).
This is what most Websites should be, just simple HTML with some CSS styling applied and maybe a few
sprinkles of JavaScript for the needed interactivity. Important Distinction: I am talking about
"normal" Websites, not Web-Apps. Web-Apps often times need to be complicated and have a lot
JavaScript to function properly, but this is not what I am against. A simple Website of a local
Sports-Club or your Personal Homepage should not need that much JS.

Okay, enough rant. Back to topic.

I found [Zine](https://zine-ssg.io/) on the inofficial Zig Discord Server. It is made by [Loris Cro](https://kristoff.it/)
and uses the Zig Build System to create the Websites and does a great job at that. Zine uses two new
file-formats: [SuperMD](https://zine-ssg.io/docs/supermd/) and [SuperHTML](https://zine-ssg.io/docs/superhtml/).
They are custom made for Zine and use some novel ideas in the Space of SSGs and Templating in
general. For example, Loris created a new Language Server for SuperHTML, which is also a Language
Server for standard HTML. He believes in catching bugs early, so his Language Server is capable of
catching malformed HTML and showing the correct errors. He found, that there is not a single HTML-LS
on the market, besides his, that can do that.

This won't be an advertisement for Zine. I am a big fan of the project, but you should look for
yourself.

There wasn't much of a reason for me to try Zine. I am a PHP-Developer, so I would be more than
capable of building a very simple Homepage or Blog. But, I thought it looks interesting, and so I
tried it. It took a little getting used to and it is still very much under development, but besides
that, it looks good. I came to like it.

This Blog is made with Zine©.

There was one Problem though...

## HTML, CSS and Me

I was never a big Frontend dev. I like logic, algorithms, problem solving. I don't like designing,
artistic thinking, CSS. I never really learned how to use it, I am scared of it and most of my
personal Projects either end with starting a UI or don't even have one. I literally choose my
projects based on wether I need a UI or not. At my dayjob I am doing mostly PHP on the Backend with
the occasional Templating and some tiny CSS, although this is mostly done and ready to use from our
existing Codebase.

I try to do as little CSS and UI-Work as I can. But sometimes, I have to do, what I have to do.

I have a little history of using Bootstrap. It got me up and running with a usable UI pretty
quickly, and my ambitions to have something more pretty are... hiding. It is nice for prototyping as
you have predefined Component Classes, which help you to quickly realise a functioning Frontend. But
if you don't customize the heck out of it, they always have this Bootstrap-y look to them. You can
tell if someone used Bootstrap on their site. Well, at least you can tell with my pages.

I also wrote some SCSS, Less and the like. They are basically standard CSS, with some extra Steps.
You have to compile your SCSS to Browser-usable CSS. The same stuff I wrote with them, I could've
just put into plain CSS.

So somewhen this or last year, I started writing the CSS myself. That works. I am still no designer,
but I now feel in complete control of my Codebase and the Design. The setup to work with Plain CSS
is so easy, there literally is none. You just include the Stylesheet in your HTML and thats it.
Start designing! While that was my go-to way of writing the limited amount of CSS I wrote, I still
did not enjoy the process of writing the actual CSS. Jumping around between HTML and CSS files,
separating the Content from the Styling felt cumbersome and annoying. While it makes sense on paper,
it is a hassle to work with. Inline-Styles a frowned upon, `<style></style>`-Tags get big very
quickly and still require to jump around the document a lot.

My CSS experience was all-in-all a solid 3/10. I got something to look at, but it ain't pretty.

## Here comes Tailwind

My Colleagues started using [Tailwind](https://tailwindcss.com/) in their personal projects. They
talked about it and somehow convinced me of trying it out. I was sceptical at first, because it
required a build-step and configuration. I liked the ease of plain CSS, quick response et cetera.
Also, it meant there was another Dependency in my project I did not fully understand the need yet.
But I wouldn't be writing this if I disliked it, would I?

I first used it on a small toy project to get feel for it. That project used a build step already so
there was not much overhead of tailwind. It also integrated well with my existing Toolchain. It was
a pleasant experience to use, there was a `watch` command to get instant rebuilds. That meant, I
could just `F5` my way to the new Styling. This incredibly fast Feedback Loop was a big reason why I
started using it more. This was inside a Symfony Project using Webpack Encore.

Then I started a different Project with Zine and wanted to integrate Tailwind into it. That was
surprisingly easy! The amazing Zig Build System™ made it possible. This is my `build.zig` file for
that project:

```zig
const std = @import("std");
const zine = @import("zine");

pub fn build(b: *std.Build) !void {
    const release = b.option(bool, "minify", "Minify Tailwind output") orelse false;

    const tailwind = b.addSystemCommand(&.{"tailwindcss"});
    tailwind.has_side_effects = true;
    _ = tailwind.captureStdErr(); // silence tailwind output

    if (release) {
        tailwind.addArg("--minify");
    }
    tailwind.addArg("--input");
    tailwind.addFileArg(b.path("assets/main.css"));
    tailwind.addArg("--output");
    const output = tailwind.addOutputFileArg("out.css");

    b.getInstallStep().dependOn(&tailwind.step);

    zine.website(b, .{
        .title = "A very nice Title",
        .host_url = "https://sample.com",
        .content_dir_path = "content",
        .layouts_dir_path = "layouts",
        .assets_dir_path = "assets",
        .build_assets = &.{
            .{ .name = "style", .lp = output, .install_path = "style.css" },
        },
    });
}
```

That's it!

Some notable things:

- I silence the Tailwind Output because I don't need it. It would pollute my console and make it
  harder to view the Zine Errors.
- I use the `addOutputFileArg(...)` function, which adds a path argument to the command, which
  points to an output file inside the `.zig-cache` directory. This way, my project directory stays
  clean without any build artifacts and I don't have to manage relative paths myself.
- `b.getInstallStep().dependOn(&tailwind.step);` ensures that tailwind gets called with every
  install. That way, Zine's watch mode is the only file watcher I need, because it calls the install
  step.
- `tailwind.has_side_effects = true;` is needed to tell the Zig Compiler "Hey, this thing should be
  ran everytime because it has side effects". Otherwise, it would only be executed on changes to the
  inputs (aka `"assets/main.css"`) due to Zigs amazing caching.

## Why all this?

Short answer: I like it that way.

Long answer:

Tailwind brings back the fun in writing Styles. It does so by removing the friction of jumping
around files and keeping the Markup and Styles close. It also enables rapid changes. Often times,
your styling directly depends on how you structure your HTML. Using Tailwind, you directly couple
those two. Making changes to your Markup lets you immediately know, what styling you have to change,
because it is right there!

## Hurdles in Zine

The way Zine (and I guess all SSGs for that matter) work, is inherently hindering to use Tailwind.
You write your content in Markdown. Splatting Tailwind all over your Markdown works directly against
the usefulnes of SSGs. But Tailwind even has an answer for that! `@apply`

`@apply` is a custom directive by tailwind, which lets you write your Tailwind Classes inline into
your CSS Stylesheet. You can create custom CSS Classes and just copy-paste tailwinds utility classes
in there, slap an `@apply` before them and boom, custom CSS classes using tailwind. Putting some
broader classes into your Markdown is manageable, Zine achieves this with custom Markdown
directives. That way you can still use Tailwind all you want, especially for your hardcoded Markup
in your templates, as well as create custom classes to be used inside the Markdown, which behind the
scenes still are powered by Tailwinds Utilities.

## Bonus: Throwing some Nix in the Mix

Making a project using Zine and Tailwind requires you to have a Zig Compiler of version `0.13.0` (as
of writing) as well as the `tailwindcss` CLI-tool. I am developing my Zig projects with Zig master,
so this not only makes me install the tailwind tool, but also managing different versions of Zig.

Thats where Nix comes into play:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zig-overlay,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        overlays = [
          (final: prev: {
            zigpkgs = zig-overlay.packages.${prev.system}."0.13.0";
          })
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [zig tailwindcss];
            shellHook = ''
              # We unset some NIX environment variables that might interfere with the zig compiler.
              # Issue: https://github.com/ziglang/zig/issues/18998
              unset NIX_CFLAGS_COMPILE
              unset NIX_LDFLAGS
              printf '\n'
              echo "Running Zig Version: $(zig version)"
            '';
          };

          packages.default = stdenv.mkDerivation {
            name = "Some fancy name";
            src = self;
            buildInputs = [zig tailwindcss];
            preBuild = "export HOME=$TMPDIR";
            installPhase = ''
              runHook preInstall
              zig build -Dminify --prefix $out install
              runHook postInstall
            '';
          };
        }
    );
}
```

This is my `flake.nix` file inside the Zine/Tailwind Project. Now, when I type `nix develop` into my
shell, Nix creates a new shell containing Zig with version `0.13.0`, as well as tailwinds CLI tool.
Just like that, I defined my development environment.

Besides that, it also defines a build command, which makes a "release" of the page. So instead of
creating a dev-server and watching files, it just builds them, tells tailwind to minify the css, and
output the resulting page files into Nix's `$out` directory. From there I can copy them to where I
need them. In my case, I set up a Gitlab Pipeline, to build the Page using this flake and just
`scp` the resulting files onto my Server.

## Conclusion

Even though I still don't like designing, I at least have fun executing on a design. Tailwind makes
quick changes to your styling easy and the overall workflow incredibly simple and fun. Using it in
conjunction with Zine was a pleasure and Nix made my life even better. I like all of these tools and
continue to use them where I can. Nix found it's way into some other projects already, as well as
all my system packages are managed by Nix. Maybe there will be another Post about Nix later, but I
am still very much new to using it.

All-in-All, working with those is a blast. 10/10, would recommend.
