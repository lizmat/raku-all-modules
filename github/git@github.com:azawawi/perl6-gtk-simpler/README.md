# GTK::Simpler [![Build Status](https://travis-ci.org/azawawi/perl6-gtk-simpler.svg?branch=master)](https://travis-ci.org/azawawi/perl6-gtk-simpler) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-gtk-simpler?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-gtk-simpler/branch/master)

This module provides a simpler API for
[GTK::Simple](https://github.com/perl6/gtk-simple). The idea here is to load
GTK::Simple widgets lazily at runtime and type less characters. For example
instead of writing the following:

```Perl6
# This is slow since it will load a lot of GTK::Simple widgets by default
use GTK::Simple;

my $app = GTK::Simple::App.new(title => "Hello");
```

you write the more concise shorter form:
```Perl6
# Exports a bunch of subroutines by default
use GTK::Simpler;

# GTK::Simple::App is loaded and created only here
my $app = app(title => "Hello");
```

## Example

```Perl6
use v6;
use GTK::Simpler;

my $app = app(title => "Hello GTK!");

$app.set-content(
    vbox(
        my $first-button  = button(label => "Hello World!"),
        my $second-button = button(label => "Goodbye!")
    )
);

$app.border-width        = 20;
$second-button.sensitive = False;

$first-button.clicked.tap({ 
    .sensitive = False; 
    $second-button.sensitive = True 
});

$second-button.clicked.tap({ 
    $app.exit; 
});

$app.run;
```

For more examples, please see the [examples](examples) folder.

## Documentation

Please see the [GTK::Simpler](doc/GTK-Simpler.md) generated documentation.

## Installation

Please check [GTK::Simple prerequisites](
https://github.com/perl6/gtk-simple/blob/master/README.md#prerequisites) section
for more information.

To install it using zef (a module management tool bundled with Rakudo Star):

```
$ zef install GTK::Simpler
```

## Testing

- To run tests:
```
$ prove -e "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -ve "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
