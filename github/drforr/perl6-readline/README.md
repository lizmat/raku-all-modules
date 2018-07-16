Readline
=======

Readline provides a Perl 6 interface to libreadline.

XXX This will probably be a frontend to Readline::Gnu when that's factored out.
XXX For the moment keep all the code here in the Readline module.

Installation
============

Please make sure that libreadline is installed beforehand, the tests will fail otherwise. If libreadline is installed but the tests still fail, please note that the Perl 6 package searches a given set of directories for libreadline.{so,dynlib}.* files, otherwise it defaults to v7. If your libreadline installation isn't on any of these paths, or requires non-standard setup, please file an issue.

For those of you on Linux Debian and Linux-alike systems, you should be able to get the latest version with this CLI invocation:

```
	sudo apt-get install libreadline7
```
(I'd prefer to use LibraryCheck, but it fails inside the 'is native()' method call.)

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
