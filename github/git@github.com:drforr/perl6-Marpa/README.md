Marpa
=======

Marpa is a Perl 6 interfae to the libmarpa C library.

Installation
============

* Marpa requires libmarpa to be present. I'd recommend installing from packages, or just look on the libmarpa website for install instructions.


* Using panda (a module management tool bundled with Rakudo Star):

```
    panda update && panda install Marpa
```

* Using ufo (a project Makefile creation script bundled with Rakudo Star) and make:

```
    ufo                    
    make
    make test
    make install
```

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Jeffrey Goff, DrForr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
