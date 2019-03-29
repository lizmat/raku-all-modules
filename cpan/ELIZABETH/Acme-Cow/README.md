[![Build Status](https://travis-ci.org/lizmat/Acme-Cow.svg?branch=master)](https://travis-ci.org/lizmat/Acme-Cow)

NAME
====

Acme::Cow - Talking barnyard animals (or ASCII art in general)

SYNOPSIS
========

```perl6
  use Acme::Cow;

  my Acme::Cow $cow .= new;
  $cow.say("Moo!");
  $cow.print;

  my $sheep = Acme::Cow::Sheep.new;    # Derived from Acme::Cow
  $sheep.wrap(20);
  $sheep.think;
  $sheep.text("Yeah, but you're taking the universe out of context.");
  $sheep.print($*ERR);

  my $duck = Acme::Cow.new(File => "duck.cow");
  $duck.fill(0);
  $duck.say(`figlet quack`);
  $duck.print($socket);
```

DESCRIPTION
===========

Acme::Cow is the logical evolution of the old cowsay program. Cows are derived from a base class (Acme::Cow) or from external files.

Cows can be made to say or think many things, optionally filling and justifying their text out to a given margin.

Cows are nothing without the ability to print them, or sling them as strings, or what not.

METHODS
=======

new
---

    my $cow = Acme::Cow.new(
      over => 0,    # optional
      wrap => 40,   # optional
      fill => True, # optional

      text => "hello world",  # specify the text of the cow
      File => "/foo/bar",     # specify when loading cow from a file
    );

Create a new `Acme::Cow` object. Optionally takes the following named parameters:

has Str $.el is rw = 'o'; has Str $.er is rw = 'o'; has Str $.U is rw = ' ';

over
----

Specify (or retrieve) how far to the right (in spaces) the text balloon should be shoved.

wrap
----

Specify (or retrieve) the column at which text inside the balloon should be wrapped. This number is relative to the balloon, not absolute screen position.

The number set here has no effect if you decline filling/adjusting of the balloon text.

think
-----

Tell the cow to think its text instead of saying it. Optionally takes the text to be thought.

say
---

Tell the cow to say its text instead of thinking it. Optionally takes the text to the said.

text
----

Set (or retrieve) the text that the cow will say or think.

Expects a list of lines of text (optionally terminated with newlines) to be displayed inside the balloon.

print
-----

Print a representation of the cow to the specified filehandle ($*OUT by default).

fill
----

Inform the cow to fill and adjust (or not) the text inside its balloon. By default, text inside the balloon is filled and adjusted.

as_string
---------

Render the cow as a string.

WRITING YOUR OWN COW FILES
==========================

{$balloon} is the text balloon; it should be on a line by itself, flush-left. {$tl} and {$tr} are what goes to the text balloon from the thinking/speaking part of the picture; {$tl} is a backslash ("\") for speech, while {$tr} is a slash ("/"); both are a lowercase letter O ("o") for thought. {$el} is a left eye, and {$er} is a right eye; both are "o" by default. Finally {$U} is a tongue, because a capital U looks like a tongue. (Its default value is "U ".) 

There are two methods to make your own cow file: the standalone file and the Perl module.

For the standalone file, take your piece of ASCII art and modify it according to the rules above. Note that the balloon must be flush-left in the template if you choose this method. If the balloon isn't meant to be flush-left in the final output, use its `over()` method.

For a Perl module, declare that your module is a subclass of `Acme::Cow`. You may do other modifications to the variables in the template, if you wish: many examples are provided with the `Acme::Cow` distribution.

HISTORY
=======

They're called "cows" because the original piece of ASCII art was a cow. Since then, many have been contributed (i.e. the author has stolen some) but they're still all cows.

SEE ALSO
========

[perl](perl), [cowsay](cowsay), [figlet](figlet), [fortune](fortune), [cowpm](cowpm)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

COPYRIGHT AND LICENSE
=====================

Original Perl 5 version: Copyright 2002 Tony McEnroe, Perl 6 adaptation: Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

