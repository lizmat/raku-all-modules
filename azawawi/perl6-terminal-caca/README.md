# Terminal::Caca [![Build Status](https://travis-ci.org/azawawi/perl6-terminal-caca.svg?branch=master)](https://travis-ci.org/azawawi/perl6-terminal-caca)

Terminal::Caca - Use libcaca (Colour AsCii Art library) API in Perl 6

**NOTE:** The library is currently **experimental**. You have been warned :)

Normally you would use the safer object-oriented API via `Terminal::Caca`. If
you need to access raw API for any reason, please use `Terminal::Caca::Raw`.

## Example

```Perl6
use v6;
use Terminal::Caca;

# Initialize library
given my $o = Terminal::Caca.new {
    # Set window title
    .title("Perl 6 rocks");

    # Say hello world
    my $text = ' Hello world, from Perl 6! ';
    .color(white, blue);
    .text(10, 10, $text);

    # Draw an ASCII-art box around it
    .thin-box(9, 9, $text.chars + 2, 3);

    # Refresh display
    .refresh;

    # Wait for a key press event
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE {
        $o.cleanup;
    }
}
```

For more examples, please see the [examples](examples) folder.

## Installation

* On Debian-based linux distributions, please use the following command:
```
$ sudo apt-get install libcaca-dev
```

* On Mac OS X, please use the following command:
```
$ brew update
$ brew install libcaca
```

* Using zef (a module management tool bundled with Rakudo Star):
```
$ zef install Terminal::Caca
```

## Testing

- To run tests:
```
$ prove -ve "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

MIT
