Readline
=======

Readline provides a Perl 6 interface to libreadline.

XXX This will probably be a frontend to Readline::Gnu when that's factored out.
XXX For the moment keep all the code here in the Readline module.

Installation
============

* Since Readline uses libreadline, libreadline.so.5 must be found in /usr/lib.
To install libreadline5 on Debian for example, please use the following command:

```
	sudo apt-get install libreadline5
```

* Using zef (a module management tool bundled with Rakudo Star):

```
    zef update && zef install Readline
```

Or alternatively installing it from a checkout of this repo with zef:

```
    zef install .
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
