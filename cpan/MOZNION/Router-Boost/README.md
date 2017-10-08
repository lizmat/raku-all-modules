[![Build Status](https://travis-ci.org/moznion/p6-Router-Boost.svg?branch=master)](https://travis-ci.org/moznion/p6-Router-Boost)

NAME
====

Router::Boost - Routing engine for perl6

SYNOPSIS
========

    use Router::Boost;

    my $router = Router::Boost.new();
    $router.add('/',                             'dispatch_root');
    $router.add('/entrylist',                    'dispatch_entrylist');
    $router.add('/:user',                        'dispatch_user');
    $router.add('/:user/{year}',                 'dispatch_year');
    $router.add('/:user/{year}/{month:\d ** 2}', 'dispatch_month');
    $router.add('/download/*',                   'dispatch_download');

    my $dest = $router.match('/john/2015/10');
    # => {:captured(${:month("10"), :user("john"), :year("2015")}), :stuff("dispatch_month")}

    my $dest = $router.match('/access/to/not/existed/path');
    # => {}

DESCRIPTION
===========

Router::Boost is a routing engine for perl6. This router pre-compiles a regex for each routes thus fast.

This library is a perl6 port of [Router::Boom of perl5](https://metacpan.org/pod/Router::Boom).

METHODS
=======

`add(Router::Boost:D: Str $path, Any $stuff)`
---------------------------------------------

Add a new route.

`$path` is the path string.

`$stuff` is the destination path data. Any data is OK.

`match(Router::Boost:D: Str $path)`
-----------------------------------

Match the route. If matching is succeeded, this method returns hash like so;

    {
        stuff    => 'stuff', # matched stuff
        captured => {},      # captured values
    }

And if matching is failed, this method returns empty hash;

HOW TO WRITE A ROUTING RULE
===========================

plain string
------------

    $router.add('/foo', { controller => 'Root', action => 'foo' });
    ...
    $router.match('/foo');
    # => {:captured(${}), :stuff(${:action("foo"), :controller("Root")})}

:name notation
--------------

    $router.add('/wiki/:page', { controller => 'WikiPage', action => 'show' });
    ...
    $router.match('/wiki/john');
    # => {:captured(${:page("john")}), :stuff(${:action("show"), :controller("WikiPage")})}

':name' notation matches `rx{(<-[/]>+)}`. You will get captured arguments by `name` key.

'*' notation
------------

    $router.add('/download/*', { controller => 'Download', action => 'file' });
    ...
    $router.match('/download/path/to/file.xml');
    # => {:captured(${"*" => "path/to/file.xml"}), :stuff(${:action("file"), :controller("Download")})}

'*' notation matches `rx{(<-[/]>+)}`. You will get the captured argument as the special key: `*`.

'{...}' notation
----------------

    $router.add('/blog/{year}', { controller => 'Blog', action => 'yearly' });
    ...
    $router.match('/blog/2010');
    # => {:captured(${:year("2010")}), :stuff(${:action("yearly"), :controller("Blog")})}

'{...}' notation matches `rx{(<-[/]>+)}`, and it will be captured.

'{...:<[0..9]>+}' notation
--------------------------

    $router.add('/blog/{year:<[0..9]>+}/{month:<[0..9]> ** 2}', { controller => 'Blog', action => 'monthly' });
    ...
    $router.match('/blog/2010/04');
    # => {:captured(${:month("04"), :year("2010")}), :stuff(${:action("monthly"), :controller("Blog")})}

You can specify perl6 regular expressions in named captures.

Note. You can't include normal capture in custom regular expression. i.e. You can't use `{year:(\d+)} `. But you can use `{year:[\d+]} `.

SEE ALSO
========

[Router::Boom of perl5](https://metacpan.org/pod/Router::Boom)

COPYRIGHT AND LICENSE
=====================

    Copyright 2015 moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Router::Boom is

    Copyright (C) tokuhirom.

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.

AUTHOR
======

moznion <moznion@gmail.com>
