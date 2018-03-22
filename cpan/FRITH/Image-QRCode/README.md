## Image::QRCode

Image::QRCode - An interface to libqrencode.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Image-QRCode.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Image-QRCode)  | Travis CI |

## Example

```Perl6
my $code = Image::QRCode.new.encode('https://perl6.org/');
my $dim = $code.qrcode.width;
my @array2D[$dim;$dim] = $code.get-data(2);
say @array2D.shape;
say @array2D;
my @array1D = $code.get-data(1);
say @array1D;
```

```Perl6
use Image::QRCode;

Image::QRCode.new.encode('https://perl6.org/').termplot;
```

For more examples see the `example` directory.

## Description

Image::QRCode provides an interface to libqrencode and allows you to generate a QR Code.

## Documentation

#### new(Int :$.version, Int :$.level, Int :$.mode, Int :$.casesensitive, Int :$.size)

Creates an **Image::QRCode** object. It may take a list of optional arguments.

The optional argument **$version** defaults to 0 (auto-select). The maximum version value is 4.

The optional argument **$level** defaults to `QR_ECLEVEL_L`. The list of possible values for this argument is provided by the **QRecLevel** enum:

* `QR_ECLEVEL_L` # lowest
* `QR_ECLEVEL_M`
* `QR_ECLEVEL_Q`
* `QR_ECLEVEL_H` # highest

The optional argument **$mode** defaults to `QR_MODE_8`. The list of possible values for this argument is provided by the **QRencodeMode** enum:

* `QR_MODE_NUL` # Terminator (NUL character). Internal use only
* `QR_MODE_NUM` # Numeric mode
* `QR_MODE_AN` # Alphabet-numeric mode
* `QR_MODE_8` # 8-bit data mode
* `QR_MODE_KANJI` # Kanji (shift-jis) mode
* `QR_MODE_STRUCTURE` # Internal use only
* `QR_MODE_ECI` # ECI mode
* `QR_MODE_FNC1FIRST` # FNC1, first position
* `QR_MODE_FNC1SECOND` # FNC1, second position

The optional argument **$casesensitive** defaults to True.

The optional argument **$size** defaults to 2. This argument is used only when generating a character based plot of the QR code to adjust the relative proportion of width vs. height.

All these arguments can be accessed directly for both reading and writing:

```Perl6
my Image::QRCode $code .= new;
$code.casesensitive = False;
```

#### encode(Str $text!, Int :$version, Int :$level, Int :$mode, Int :$casesensitive)

Encodes a string. It takes one *mandatory* argument: **text**, the string to encode. All the other arguments are optional.

This method put a QR code in the attribute **qrcode**, an object of class QRcode, which can be read directly or managed by other methods.

The class **QRcode** is an interface to the library's internal structure of a QR code. It has three attributes:

* int32 $.version
* int32 $.width
* CArray[uint8] $.data

Even if the **data** attribute can be accessed directly, its representation is a bit complex and most of the coded information is not very useful. The original library's documentation goes as follows:

```
Symbol data is represented as an array contains width*width uchars.
Each uchar represents a module (dot). If the less significant bit of
the uchar is 1, the corresponding module is black. The other bits are
meaningless for usual applications, but here its specification is described.

MSB 76543210 LSB
    |||||||`- 1=black/0=white
    ||||||`-- data and ecc code area
    |||||`--- format information
    ||||`---- version information
    |||`----- timing pattern
    ||`------ alignment pattern
    |`------- finder pattern and separator
    `-------- non-data modules (format, timing, etc.)
```

#### get-data($dimension)

This method returns the QR code data, encoded as a 1D or 2D array. The argument **dimension** can be 1 or 2: passing a dimension = 1 the method returns a linear array of the values of all the dots, coded as 0 (black) or 1 (white). A value of 2 makes the method return an array of arrays.

#### termplot(Int :$size)

This method accepts the optional parameter **size**, which determines the orizontal stretch of the "image". It prints the QR code on the terminal screen as `\c[FULL BLOCK]` characters. It returns a Failure object if there's no data to plot.

## Low level calls

This module provides an interface to all the C library's functions. The library's full documentation can be found here:

[https://fukuchi.org/works/qrencode/manual/index.html](https://fukuchi.org/works/qrencode/manual/index.html)

Its GitHub page is:

[https://github.com/fukuchi/libqrencode](https://github.com/fukuchi/libqrencode)

## Prerequisites
This module requires the libqrencode3 library to be installed. Please follow
the instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libqrencode3
```

## Installation

To install it using zef (a module management tool):

```
$ zef update
$ zef install Image::QRCode
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

## Note

Image::QRCode relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl6 module.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
