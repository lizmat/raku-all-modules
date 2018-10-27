# Graphics::PLplot
[![Build Status](https://travis-ci.org/azawawi/perl6-graphics-plplot.svg?branch=master)](https://travis-ci.org/azawawi/perl6-graphics-plplot) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-graphics-plplot?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-graphics-plplot/branch/master)

This module provides Perl 6 low and high-level native bindings for
[PLplot](http://plplot.sourceforge.net/).

Note: Currently work in progress and the API is being implemented one brick at
a time. Help and feedback is appreciated.

PLplot is a library of subroutines that are often used to make scientific plots
in various compiled languages. PLplot can also be used interactively by
interpreted languages such as Octave, Python, Perl and Tcl. The current version
was written primarily by Maurice J. LeBrun and Geoffrey Furnish and is licensed
under LGPL.

## Example

```Perl6
use v6;
use Graphics::PLplot;

if Graphics::PLplot.new(
    device    => "png",
    file-name => "output.png"
) -> $plot  {

    # Begin plotting
    $plot.begin;

    # Create a labeled box to hold the plot.
    my $y-max = 100;
    $plot.environment(
        x-range => [0.0, 1.0],
        y-range => [0.0, $y-max],
        just    => 0,
        axis    => 0,
   );
    $plot.label(
        x-axis => "x",
        y-axis => "y=100 x#u2#d",
        title  => "Simple PLplot demo of a 2D line plot",
   );

    # Prepare data to be plotted.
    constant NSIZE = 101;
    my @points = gather {
        for 0..^NSIZE -> $i {
            my $x = Num($i) / (NSIZE - 1);
            my $y = Num($y-max * $x * $x);
            take ($x, $y);
        }
    };

    # Plot the data that was prepared above.
    $plot.line(@points);

    LEAVE {
        $plot.end;
    }
}
```

For more examples, please see the [examples](examples) folder.

## Installation

* On Debian-based linux distributions, please use the following command:
```
$ sudo apt install libplplot-dev
```

* On Mac OS X, please use the following command:
```
$ brew update
$ brew install plplot
```

* Using zef (a module management tool bundled with Rakudo Star):
```
$ zef install Graphics::PLplot
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
