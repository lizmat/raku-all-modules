NAME
====

Slang::AltTernary - an alternative (additional) Perl6 ternary statement.

SYNOPSIS
========

    use Slang::AltTernary;

    ^10.pick < 5 ?⁈
        Yes say "Heads"
        No  say "Tails";

DESCRIPTION
===========

Slang::AltTernary is a toy for learning about modifying perl6 parsing with slangs.

It adds a new infix operator, ?⁈, (that's a '?' followed by U+2048) which 
functions in much the same way as perl6's ternary operator 'infix::<?? !!>'.  

The difference is instead of seperating the truthful branch from the falsey 
branch with '!!', AltTernary preceedes the truthful branch with 'Yes' and
the falsey branch with 'No'.

It's not intended that this module be used for anything other than exploring
the use of slangs - use in any real code is discouraged.  You've been warned.

AUTHOR
======

Martin Ryan <mryan50@fastmail.fm>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Martin Ryan

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

