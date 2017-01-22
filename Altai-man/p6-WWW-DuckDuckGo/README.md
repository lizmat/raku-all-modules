NAME
====

WWW::DuckDuckGo - API bindings for DuckDuckGo search engine.

SYNOPSIS
========

```perl6
    use WWW::DuckDuckGo;
    my $duck = WWW::DuckDuckGo.new;
    my $zeroclickinfo1 = $duck.zci('duck duck go');
    my $zeroclickinfo2 = $duck.zci('one', 'another');
```

DESCRIPTION
===========

This class provides a way to get data from DuckDuckGo search service. The basic idea is to create a class instance that represents JSON answer from the server for every query.

This is a functional port of the Perl 5 module of the same name by Torsten Raudssus and Michael Smith, see [WWW::DuckDuckGo](https://metacpan.org/pod/WWW::DuckDuckGo), all bugs with this port must be reported here, not to the original module bugzilla.

COPYRIGHT
=========

This library is free software; you can redistribute it and/or modify it under the terms of the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)
