# Name

DEBUG - Experimental debugging macros

# Synopsis

```
    perl6 -MDEBUG -e 'use dbg; dbg note "debugging..."'
    perl6 -MDEBUG -e 'use assert; assert 0 > 1'
    perl6 -MDEBUG -e 'use logger; logger "hello world"'
```

```
    use dbg;
    use assert &warn;
    use logger &say;

    use DEBUG;

    logger 'Printing to STDOUT...';
    dbg say 'Also prints to STDOUT...';
    assert !'Only a warning';

    use NDEBUG <logger>;

    dbg note 'Logging disabled';
    logger do {
        sleep(42);
        'This will never be executed...';
    };

    use DEBUG <logger>;

    dbg note 'Logging enabled';
    logger 'Alive!';
```

# Bugs and Development

Development happens at [GitHub](https://github.com/cygx/p6-debug). If you
found a bug or have a feature request, use the
[issue tracker](https://github.com/cygx/p6-debug/issues) over there.


# Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt)
