[![Build Status](https://travis-ci.org/holli-holzer/perl6-Test-Color.svg?branch=master)](https://travis-ci.org/holli-holzer/perl6-Test-Color)

NAME
====

Test::Color - Colored Test - output

SYNOPSIS
========

    use Test;
    use Test::Color;
    use Test::Color sub { :ok("blue on_green"), :nok("255,0,0 on_255,255,255") };

DESCRIPTION
===========

Test::Color uses [Terminal::ANSIColor](https://github.com/tadzik/Terminal-ANSIColor) to color your test output. Simply add the `use Color` statement to your test script.

Setup
-----

If you don't like the default colors, you can configure them by passing an anonymous sub to the use statement.

The sub must return a hash; keys representing the output category (one of <ok nok comment bail-out plan default>), and the values being color commands as in [Terminal::ANSIColor](https://github.com/tadzik/Terminal-ANSIColor).

You can tweak the behaviour even further by setting output handles of the `Test` module directly.

    Test::output()         = Test::Color.new( :handle($SOME-HANDLE) );
    Test::failure_output() = Test::Color.new( :handle($SOME-HANDLE) );
    Test::todo_output()    = Test::Color.new( :handle($SOME-HANDLE) );

Caveat
------

This module works using escape sequences. This means that test suite runners will most likely trip over it. The module is mainly meant for the development phase, by helping to spot problematic tests in longish test outputs.

AUTHOR
======

    Markus 'Holli' Holzer

COPYRIGHT AND LICENSE
=====================

Copyright © holli.holzer@gmail.com

License GPLv3: The GNU General Public License, Version 3, 29 June 2007 <https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
