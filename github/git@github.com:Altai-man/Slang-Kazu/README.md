[![Build Status](https://travis-ci.org/Altai-man/Slang-Kazu.svg?branch=master)](https://travis-ci.org/Altai-man/Slang-Kazu)

NAME
====

Slang::Kazu - Japanese numerals in your Perl 6

SYNOPSIS
========

    use Slang::Kazu;
    say "3542" ~~ 三千五百四十二; # True
    say '一' ~~ /<single-kazu>/; # Will match any digit from 1 to 9


DESCRIPTION
===========

Slang::Kazu is a Perl 6 slang that allows you to use a subset of native Japanese numerals in your Perl 6 code because you can.

You can use numbers from 1 to 99999. Counters are yet to be implemented. Mostly this is a clone of [drforr's](http://github.com/drforr) `Slang::Roman`, but for Japanese numerals - all thanks to him for the idea and the implementation.

Currently, incorrect numbers like `二二` are evaluated to `Nil` and you will see some scary errors because of that, so don't lose your kanji!

This project is just a joke and doesn't intented to be used in any serious codebases! You are warned.

AUTHOR
======

Altai-man on Github, you can cast sena_kun on freenode too.

COPYRIGHT AND LICENSE
=====================

Copyright © 

License GPLv3: The GNU General Public License, Version 3, 29 June 2007 <https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
