---
title: Open Source Corner
pubDatetime: 2026-05-06T10:00:00
draft: true
featured: true
tags:
  - open source
  - self host
  - free software
description:
  I love self hosting open source software. My raspberry pi already hosts
  quite a bit of software for me and the number is still growing. This is a
  collection of all the fancy software I am hosting and some details about them.
---

I love self hosting. I don't really have what you could call a homelab, just a
simple Raspberry Pi 4. This little guy is all I need for all of my hosting
needs. It is sitting in my room and fullfills (for now) all my server needs. It
even serves you this exact site! Since setting it up and hosting my homepage on
it, I added a lot of other software to host on it, either stuff I've written
myself or open source software I find cool, useful or both. I will now try to
document all of the open source software I am hosting and note down some reasons
I am hosting that and maybe some experiences on setting everything up.

## Table of contents

## Setup

### Hardware

Before we can talk about hosting, we need to talk about my setup first. I
already told you that I am using a Raspberry Pi 4 (4 GB RAM version to be
precise) as the server. This is definitely enough for a lot of self hosting, but
depending on the software you host and the amount of traffic you produce, this
can get a little rough. For my case this is still enough but I did think about
investing in a Hetzner VPS for some time now and will probably do that when my
software suite expands even more. I reached a point where I really look at the
minimum requirements of the software I host because there is not much RAM left.
RAM being the limitting factor because I do not have lots of traffic and I just
upgraded the disk space by using a different USB Drive with 256 GB.

### Infrastructure

Normally you want to be able to give your friends a name of a website to look
up, not the server IP. For that you need a domain. I decided to go with IONOS as
my domain provider. They are a german company and I used them before and had
good experience with them. I still think they are a good provider and
recommend them for other people as well. I bought the domain `nkoll.de`, because
`koll.de` was already gone unfortunately. This costs me a fortune of 15.60 € a
year or 1.30 € a month. Really not expensive. Included is a single small E-Mail
inbox and multiple E-Mail redirections, the latter of which I haven't tried out
yet. More importantly, the domain also includes SSL Certificates for free. They
are valid for 6 months, compared to those of other free certificate authorities
like LetsEncrypt. You can't really autorenew those though, so you have to
manually go ahead and change them, if you host the website yourself. Also, the
certificates are wild card certificates, so you only have to serve a single
cert for all your apps and sites. But they do send you a reminder mail before
they expire so you have enough time to exchange them before it causes problems.

### Software

The software side of self hosting consists of 3 main parts. Operating System,
Reverse Proxy and Docker.

Operating System on the raspberry pi is simply the Raspberry Pi OS, the debian
based official OS from Raspberry Pi. Almost all tutorials you find online
(without searching for specific OS) will use some kind of debian/ubuntu based
system. So stuff like `apt` as the package manager will be the same and you can
mostly follow the tutorials without changes.

For the reverse proxy I use plain old NGINX. This is mostly because it's the
most widespread webserver solution, that was also used in the PHP Era of my
career the most so I already knew the basics and could work with it without
learning something new. Also, it just works, can serve files directly (which is
good for my love of statically generated pages) or proxy to a different service
and is rock solid. Except some difficulties with remotely writing config files,
I had really no issues with using it. The domain is set to point to the
raspberry pi on `nkoll.de` and `*.nkoll.de`, so every subdomain already has the
entry to point to the pi. The distinction between the subdomains happen inside
NGINX. I have a separate configuration for every service. Also there is a
fallback for unknown subdomains that redirect back to `www.nkoll.de` with a `302
Found` temporary redirect. This causes the client to not cache the redirection,
so I have no problems when adding services to wait until the cache is cleared.
Also HTTP is redirect to HTTPS, always. We want to be secure.

Docker is the last main part. This is _technically_ not needed for the whole
stack as I have quite a few statically generated apps/pages that NGINX serves
directly, but for serious apps that need a backend docker is the way to go.
Every service gets its own folder with a `docker-compose.yml` where the services
are configured and data is mounted locally into that folder. This means, I have
no "global" docker containers or services running and all apps are easily found
when I have to change something in the configuration. Docker is also the
industry standard for container software so most, if not all, software that is
available to selfhost already has a docker image ready for you to use.

Now lets see what my raspberry pi is serving to the world.

## [ForgeJo](https://forgejo.org/)

This is an open source git forge. That basically means, it's an alternative to
GitHub, GitLab, Bitbucket and whatever else your company decided to pay for.
There is also [Codeberg](https://codeberg.org/), which is powered by forgejo,
that is a free, independant git forge hosted by a non-profit in Berlin. I
migrated almost all my projects to [forgejo](https://git.nkoll.de/) by now. It's
UI is arguably a bit uglier than the paid services, but the usability is on par.
It even has it's own CI/CD solution which mirrors GitHub's actions and is even
compatible with them. Even though it has the largest CPU usage of all docker
containers running, it is the third largest RAM user, but considering that it
also receives by far the most traffic by me, the absolute values are still
incredibly lightweight. Right now, forgejo by itself has about 6% CPU usage and
takes about 250-300 MB RAM. I do use it by myself, so no other users are putting
any pressure on the system but it is by far the app I, as a software developer,
use the most. Compared to hosting GitLab for example, this is pretty much
nothing. A friend of mine hosts a GitLab instance and he has a CPU usage 4%, but
it uses 5.2 GB of RAM! So if you want to _own_ your data and git repositories,
but can't afford a server with enough resources to host GitLab, give ForgeJo a
try. Give it a try anyways, it's really easy to setup and use.

## [Linkwarden](https://linkwarden.app/)

## [Beszel](https://beszel.dev/)

## [Tandoor](https://tandoor.dev/)

## [Excalidraw](https://excalidraw.com/)

Yes, you can selfhost. It's just a single, small docker image.

It's missing the collaboration features, but if you only use it by yourself,
this is a fun little thing you can self host for the sake of it.

## [Gokapi](https://github.com/Forceu/Gokapi)

## [Penpot](https://penpot.app/)
