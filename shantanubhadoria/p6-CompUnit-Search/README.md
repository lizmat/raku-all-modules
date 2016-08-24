NAME
====

CompUnit::Search - Search through compunits

SYNOPSIS
========

Search through compunits
------------------------

        use CompUnit::Search;

        my @modules = installed-compunits({$_ ~~ /Test\:\:.*/});

        for @modules -> $module {
          say $module;
        }

METHODS
=======

search-compunits
----------------

Gets a list of all installed compunits from the repositories(optional filter can be passed to show a subset of the installed compunits). Note that at the moment this only searches in repositories of type CompUnit::Repository::Installation, as these are the only ones which provide a quick meta to search for installed modules. If you install anything through `panda install` it should show up in the list. Once there is a good way to search through other repositories I will implement it here.

Returns a lazy list of Pair(s) with compunits as key and a Seq of its provides as the value.

    use CompUnit::Search;

    my @compUnits = search-compunits(* ~~ /JSON\:\:.*/); # Whatever code as a parameter to filter the compunits by name
                                                         # You may also use a block with one parameter(compunit name)
                                                         # instead for filtering purposes.

    for @compUnits -> $compUnit {
      say $compUnit;
    }

Output:

    JSON::Unmarshal => (JSON::Unmarshal)
    JSON::Marshal => (JSON::Marshal)
    JSON::Tiny => (JSON::Tiny JSON::Tiny::Actions JSON::Tiny::Grammar)
    JSON::Pretty => (JSON::Pretty)
    JSON::Class => (JSON::Class)
    JSON::Infer => (JSON::Infer)
    JSON::RPC => (JSON::RPC::Server X::JSON::RPC JSON::RPC::Client)
    JSON::Name => (JSON::Name)
    JSON::Fast => (JSON::Fast)

search-provides
---------------

Gets a list of provides and the compunits that provide them. This function filters based on the provides' name. Provide can be a package, class, role, module, grammar etc. as specified in the Meta file for the compunit. Returns a lazy list of Pair(s) with a provide as the key and the compunit that provides that provide as the value.

    use CompUnit::Search;

    my @compUnits = search-provides(* ~~ /JSON\:\:.*/);

    for @compUnits -> $compUnit {
      say $compUnit;
    }

Output:

    JSON::Unmarshal => JSON::Unmarshal
    JSON::Marshal => JSON::Marshal
    JSON::Tiny => JSON::Tiny
    JSON::Tiny::Actions => JSON::Tiny
    JSON::Tiny::Grammar => JSON::Tiny
    JSON::Pretty => JSON::Pretty
    JSON::Class => JSON::Class
    JSON::Infer => JSON::Infer
    JSON::RPC::Server => JSON::RPC
    X::JSON::RPC => JSON::RPC
    JSON::RPC::Client => JSON::RPC
    JSON::Name => JSON::Name
    JSON::Fast => JSON::Fast

REFERENCE
=========

Compilation Units http://design.perl6.org/S11.html

SUPPORT
=======

Bugs / Feature Requests
-----------------------

Please report any bugs or feature requests through github at [https://github.com/shantanubhadoria/p6-CompUnit-Search/issues](https://github.com/shantanubhadoria/p6-CompUnit-Search/issues). You will be notified automatically of any progress on your issue.

Source Code
-----------

This is open source software. The code repository is available for public review and contribution under the terms of the license.

[https://github.com/shantanubhadoria/p6-CompUnit-Search](https://github.com/shantanubhadoria/p6-CompUnit-Search)

    git clone git://github.com/shantanubhadoria/p6-CompUnit-Search.git

AUTHOR
======

Shantanu Bhadoria <shantanu@cpan.org> [https://www.shantanubhadoria.com](https://www.shantanubhadoria.com)

COPYRIGHT AND LICENSE
=====================

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 6 programming language system itself.
