# GLFW Perl 6 Wrapper

Very much a work in progress.  Thoroughly untested.  Use at your own
risk.

## ...But Why?

I wanted to learn Perl 6, and I wanted to learn GLFW.  Both are still
in progress.

## How complete is it?

Well, the full GLFW API is (as far as I can tell) implemented, and
most things are wrapped up in classes to provide a nice Perlish
object-oriented interface.  However...

## How correct is it?

Not all all, I'm sure.  The simple example (`doc/example/test.pl6`)
runs on my machine (running Slackware64-current w/ both Intel and AMD
graphics), but beyond that, all bets are off.  I *am* using this for
some personal projects, so as I run into things I'm bound to fix them.
If you beat me to it, please submit a PR.

There are also some organizational issues.  For example, some things
are in what I am sure are very weird places, and some things are plain
old constants when they should be Enums.  I'll be fixing those soon.
