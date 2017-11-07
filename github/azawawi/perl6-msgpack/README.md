# MsgPack

 [![Build Status](https://travis-ci.org/azawawi/perl6-msgpack.svg?branch=master)](https://travis-ci.org/azawawi/perl6-msgpack) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-msgpack?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-msgpack/branch/master)
 
Perl 6 Interface to libmsgpack

## Example

```Perl6
use v6;
use MsgPack;

my $data     = [1, True, "Example", { "that" => "rocks" }];
my $packed   = MsgPack::pack($data);
my $unpacked = MsgPack::unpack($packed);

say "data     : " ~ $data.perl;
say "packed   : " ~ $packed.perl;
say "unpacked : " ~ $unpacked.perl;
```

For more examples, please see the [examples](examples) folder.

## Installation

- Please follow the section below to install `libmsgpack` on your system.

- Install it using zef (a module management tool bundled with Rakudo Star):

```
$ zef install MsgPack
```

## Dependencies

Please follow the instructions below based on your platform:

### Linux (Debian)

- To install `msgpack` development headers / libraries, please run:
```
$ sudo apt-get install libmsgpack-dev
```

## macOS

- To install `msgpack` development headers / libraries, please run:
```
$ brew update
$ brew install msgpack
```

## Windows

Not supported at the moment but planned as a pre-built DLL in the near future.

TODO support windows with a pre-built DLL

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

## See Also

- [Data::MessagePack](https://github.com/pierre-vigier/Perl6-Data-MessagePack/)

    Most of the excellent tests here are based of the work of
    [Pierre Vigier](https://github.com/pierre-vigier/).
    Thanks for creating an excellent pure Perl 6 reference implementation.

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
