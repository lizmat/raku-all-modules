# OpenCV
[![Build Status](https://travis-ci.org/azawawi/perl6-opencv.svg?branch=master)](https://travis-ci.org/azawawi/perl6-opencv)
[![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-opencv?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-opencv/branch/master)

This provides a simple Perl 6 object-oriented NativeCall wrapper for the
[OpenCV](http://opencv.org) library.

## Example

```Perl6
use v6;
use OpenCV;

# Read the image from the disk
my $image = imread( "sample.png" );

# Show the image in a window
namedWindow( "Sample", 1 );
imshow( "Sample", $image );

# Wait for a key press to exit
waitKey;
```

For more examples, please see the [examples](examples) folder.

## OpenCV Installation

Please follow the instructions below based on your platform:

### Linux (Debian)

- To install OpenCV 2.4 development libraries, please run:
```
$ sudo apt-get install libopencv-dev g++
```

## macOS

- To install OpenCV 2.4 development libraries, please run:
```
$ brew update
$ brew tap homebrew/science
$ brew install opencv
```

## Windows

A precompiled 64-bit windows DLL binary is already provided so it should work
on 64-bit windows operating systems.

## Installation

To install it using zef (a module management tool bundled with Rakudo Star):

```
$ zef install OpenCV
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
$ AUTHOR_TESTING=1 prove -ve "perl6 -Ilib"
```

## Development Notes

If you need to change the C++ to C library wrapper without doing a
`zef install .`, please run:
```
$ zef build .
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

MIT License
