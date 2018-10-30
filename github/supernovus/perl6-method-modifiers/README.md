# Method::Modifiers

## Introduction

Implements before(), after() and around() functions that can be used to
modify class methods similarly to Perl 5's Moose. It uses wrap() internally,
and returns the wrapper handler, so it is easy to .restore() the original.

Has an optional augmentation version that adds the aforementioned functions
as methods to the Any class. Mostly just a candy coating, and not really
recommended. Use the functions, they're straightforward and don't modify
the base classes.

## Examples

See the tests in "t/" for a few good examples.

## Status

The basic function version works. The augment version doesn't due to a
Rakudo bug. That's okay, as I mentioned above, the augment version isn't
really recommended anyway.

## Author

[Timothy Totten](https://github.com/supernovus/)

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

