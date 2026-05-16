---
title: "Keyboard Journey Part 2: Months later"
pubDatetime: 2026-05-16T15:00:00
tags:
  - keyboard
  - experience
description:
  My experience with the split keyboard after a little less than a year of
  typing.
---

This is a small update. I wanted to keep better track of the experience but as
it happens to be, life and other topics got more important so I just forgot.
Anyways, I promised updates so I will now give it.

About 9 months passed since the first post and in this time I got used to the
keyboard and use exclusively that, with the only exception being the builtin
keyboard of a Laptop when I am not sitting at a desk. This means I made some
small adjustments to my layout. For example, I now switched from the VIAL-based
firmware, which allowed visually changing the layout through a web based
application without reflashing the keyboard, to raw-dogging QMK, which is the
OpenSource keyboard firmware that supports basically all keyboards and is
actually the base of VIAL as well. That means I didn't need to change the base
firmware. Instead I only turned VIAL off and make my keybinds through C-Code and
reflashing the keyboard. The source for my current keyboard can be viewed
[here](https://github.com/nihklas/vial-qmk/tree/nkoll/keyboards/nihklas/sofle_choc_pro).

## Layout changes

The biggest change about my keymap is probably the switch to a german based
layout. I am german, so most of the computers I will use come stock with a
german QWERTZ layout. I made my keyboard compatible with it, so I don't have to
change the layout in the computer settings and the keyboard works plug'n'play.
My base layer is still english first though, so I added an extra layer to type
Umlaute like `äöü` and `ß`. Those are used rarely enough that I don't need the
reachable without a layer switch and I can keep my english and coding focused
layout. I also added a kind of complicated logic to switch between Linux and
MacOS based keys. They differ especially in the special characters and
unfortunately for coding the important characters like the brackets etc are
pretty different. That means I can toggle different base layers to switch
between Mac and Linux. _Technically_ QMK is able to detect the OS, but I think I
remember this feature sometimes being unreliable so I thought I needed that
manual toggle anyways. Since I also needed it like twice a day at maximum
anyways, I just did the manual toggle and skipped the automatic switch. All of
that is outdated anyways since I got a new job where I also work on MacOS so I
don't even need the switch anymore. I could remove it from the layout but it's
not in the way and if I get to use a Linux machine with my keyboard I can still
switch over.

I also added in a "Gaming-Layer". That is mainly there to get back the classic
`WASD` and a few other keys all on the left half of the keyboard so I can use my
right hand for the mouse only.

Last but not least, I added some smaller but useful Macro keys. For example
Spotlight Search for MacOS, Screenshot, shortcuts for common coding patterns
like `->` and `=>`. If I come up with more useful shortcuts I will definitely
add them as well. I put all the Macros on a separate layer so I can access every
Macro with just two keys, one of which is always the same, instead of
remembering a lot of different key combinations that you use _just_ rarely
enough to not being able to remember them. For anyone that has access to QMK for
their own keyboard, a separate Macro layer and Macros in general is probably the
biggest benefit I would tell everyone to use if they can.

## New switches

I ordered myself a new set of switches because I wanted to have a little bit
better feedback while typing. I chose the brown tactical switches when I bought
the keyboard but since I got used to typing on linear switches before I had
quite a few mistypes because I didn't put enough pressure on the key. I ordered
the [switch tester v1](https://www.keebart.com/de/produkte/switch-tester) with
keycaps so I can choose the best feeling switch for me. I landed on the [sunset
switches](https://www.keebart.com/de/produkte/sunset-choc). They are also
tactical but have less actuation force or in other words are easier to press.
They are also more quiet and just feel a bit better. I forgot to include a
keycap puller when ordering the keyboard so I contacted the owner of keebart
directly and asked how I should go about telling them to include one, as they
didn't appear on their site as a separate product. He simply told me to add a
note on the order and they would include one for free. This, their discord
server and the whole experience with the store was incredibly nice and easy. If
anyone wants to get a split keyboard, please take a look at
[keebart](https://www.keebart.com/) first. They have a few different options,
both wired and wireless and the customer support is just amazing. Also it is
pretty much the only store located in germany that actually sells them
pre-built. The alternative would be to order overseas and pay highter tax and
customs or order/make the parts separately and build the keyboard yourself.

## Typing Speed

I didn't practice my typing speed in particular but that wasn't my priority
anyways. I just did a small test on [monkeytype](https://monkeytype.com/) which
resulted in about 80 WPM. I think that is a pretty passable speed and is about
the same speed I had with my previous 75% mechanical keyboard. I don't have to
goal of getting even faster but 80 WPM is comfortable speed to work with so I
don't have to spend a lot of thinking to type.

I also started with a console based typing speed tester as a side project.
Anyone who is interest can view it [here](https://git.nkoll.de/nk/terminal-wpm).
While I practiced on monkeytype, I wanted to be able to do it on the terminal
instead. My reasoning is that (for me) it is much faster to open up a new
terminal window, start the typing speed test and close it again, in case I have
a small amount of wait time in between tasks or I quickly want to practice
typing on the side. Switching to the browser, opening a new tab with monkeytype,
start typing and then looking at the results is even with good usage of hotkeys
slower than my terminal based solution. I still use monkeytype for most of the
typing practice when I deliberately want to practice, but for the short, small
tests in between work, a terminal based test is just more comfortable for me.

## Conclusion after 9 months

8/10. Once you get the hang of it, the keyboard is amazing to type on. Having it
split and pushing the halves basically anywhere my hands feel comfortable is
amazing. The learning curve is _steep_. All in all, I would buy one again, but I
wouldn't necessarily recommend it to everyone. It is definetly a commitment to
use, other people are basically inable to use your computer (unless you have a
spare QWERTY laying around) and you can get most of the benefits with other,
standard mechanical keyboards that are supported by QMK anyways.
