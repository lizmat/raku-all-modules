# Clean

[![Build Status](https://travis-ci.org/azawawi/perl6-clean.svg?branch=master)](https://travis-ci.org/azawawi/perl6-clean) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-clean?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-clean/branch/master)

Provides a routine `clean` that takes an object and an anonymous code block
which takes an object that does `Cleanable`. This basically ensures that your
objects can be cleaned after your code block has finished running. Thus it
provides an object-oriented `clean` method (aka destructor).

## Example

```Perl6
# A class that needs to close or free resources
class Foo does Cleanable {

  # Guaranteed to be called once the anonymous block finishes execution
  method clean {
    # Close or free resources here
  }
}

clean(
  # The object we need to be cleaned up
  Foo.new,

  # The anonymous block
  -> $obj {
    # Do interesting stuff with $obj of type Cleanable
  }
);
```


## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install Clean
```

## Testing

To run tests:

```
$ prove -e "perl6 -Ilib"
```

To run author tests, you need to manually install [Test::META](
https://github.com/jonathanstowe/Test-META):

```
$ panda install Test::META
$ TEST_AUTHOR=1 prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

MIT License
