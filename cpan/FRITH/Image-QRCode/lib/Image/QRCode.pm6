use v6;
unit class Image::QRCode:ver<0.0.1>;

use NativeCall;

constant LIB = ('qrencode', v3);

# Encoding mode
enum QRencodeMode is export(:constants) «:QR_MODE_NUL(-1) QR_MODE_NUM QR_MODE_AN QR_MODE_8 QR_MODE_KANJI QR_MODE_STRUCTURE QR_MODE_ECI QR_MODE_FNC1FIRST QR_MODE_FNC1SECOND»;
# Level of error correction
enum QRecLevel is export(:constants) <QR_ECLEVEL_L QR_ECLEVEL_M QR_ECLEVEL_Q QR_ECLEVEL_H>;
# Maximum version (size) of QR-code symbol
constant QRSPEC_VERSION_MAX is export(:constants) = 40;
# Maximum version (size) of QR-code symbol
constant MQRSPEC_VERSION_MAX is export(:constants) = 4;

class QRinput is repr('CPointer') is export { * } # libqrencode private struct
class QRinput_Struct is repr('CPointer') is export { * } # libqrencode private struct

class QRcode is repr('CStruct') is export {
  has int32 $.version;
  has int32 $.width;
  has CArray[uint8] $.data;
}
class QRcode_List is repr('CStruct') is export {
  has QRcode $.code;
  has QRcode_List $.next;
}

sub QRinput_new(--> QRinput) is native(LIB) is export { * }
sub QRinput_new2(int32 $version, int32 $level --> QRinput) is native(LIB) is export { * }
sub QRinput_newMQR(int32 $version, int32 $level --> QRinput) is native(LIB) is export { * }
sub QRinput_append(QRinput $input, int32 $mode, int32 $size, Str $data --> int32) is native(LIB) is export { * }
sub QRinput_appendECIheader(QRinput $input, uint32 $ecinum --> int32) is native(LIB) is export { * }
sub QRinput_getVersion(QRinput $input --> int32) is native(LIB) is export { * }
sub QRinput_setVersion(QRinput $input, int32 $version --> int32) is native(LIB) is export { * }
sub QRinput_getErrorCorrectionLevel(QRinput $input --> int32) is native(LIB) is export { * }
sub QRinput_setErrorCorrectionLevel(QRinput $input, int32 $level --> int32) is native(LIB) is export { * }
sub QRinput_setVersionAndErrorCorrectionLevel(QRinput $input, int32 $version, int32 $level --> int32) is native(LIB) is export { * }
sub QRinput_free(QRinput $input) is native(LIB) is export { * }
sub QRinput_check(int32 $mode, int32 $size, Str $data --> int32) is native(LIB) is export { * }
sub QRinput_Struct_new(--> QRinput_Struct) is native(LIB) is export { * }
sub QRinput_Struct_setParity(QRinput_Struct $s, uint8 $parity) is native(LIB) is export { * }
sub QRinput_Struct_appendInput(QRinput_Struct $s, QRinput $input --> int32) is native(LIB) is export { * }
sub QRinput_Struct_free(QRinput_Struct $s) is native(LIB) is export { * }
sub QRinput_splitQRinputToStruct(QRinput $input --> QRinput_Struct) is native(LIB) is export { * }
sub QRinput_Struct_insertStructuredAppendHeaders(QRinput_Struct $s --> int32) is native(LIB) is export { * }
sub QRinput_setFNC1First(QRinput $s --> int32) is native(LIB) is export { * }
sub QRinput_setFNC1Second(QRinput $s, uint8 $appid --> int32) is native(LIB) is export { * }
sub QRcode_encodeInput(QRinput $input --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeString(Str $string, int32 $version, int32 $level, int32 $mode, int32 $casesensitive --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeString8bit(Str $string, int32 $version, int32 $level --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeStringMQR(Str $string, int32 $version, int32 $level, int32 $mode, int32 $casesensitive --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeString8bitMQR(Str $string, int32 $version, int32 $level --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeData(int32 $size, Str $data, int32 $version, int32 $level --> QRcode) is native(LIB) is export { * }
sub QRcode_encodeDataMQR(int32 $size, Str $data, int32 $version, int32 $level --> QRcode) is native(LIB) is export { * }
sub QRcode_free(QRcode $qrcode) is native(LIB) is export { * }
sub QRcode_encodeInputStructured(QRinput_Struct $s --> QRcode_List) is native(LIB) is export { * }
sub QRcode_encodeStringStructured(Str $string, int32 $version, int32 $level, int32 $mode, int32 $casesensitive --> QRcode_List) is native(LIB) is export { * }
sub QRcode_encodeString8bitStructured(Str $string, int32 $version, int32 $level --> QRcode_List) is native(LIB) is export { * }
sub QRcode_encodeDataStructured(int32 $size, Str $data, int32 $version, int32 $level --> QRcode_List) is native(LIB) is export { * }
sub QRcode_List_size(QRcode_List $qrlist --> int32) is native(LIB) is export { * }
sub QRcode_List_free(QRcode_List $qrlist --> int32) is native(LIB) is export { * }
sub QRcode_APIVersion(int32 $major_version is rw, int32 $minor_version is rw, int32 $micro_version is rw) is native(LIB) is export { * }
sub QRcode_APIVersionString(--> Str) is native(LIB) is export { * }
sub QRcode_clearCache() is native(LIB) is export { * }

# OO interface

has Int $.version       is rw = 0;
has Int $.level         is rw = QR_ECLEVEL_L;
has Int $.mode          is rw = QR_MODE_8;
has Int $.casesensitive is rw = True;
has Int $.size          is rw = 2;
has QRcode $.qrcode;

constant OK is export(:constants) = 1;

method encode(Str $text!, Int :$version, Int :$level, Int :$mode, Int :$casesensitive)
{
  $!qrcode = QRcode_encodeString($text,
    $version // $!version,
    $level // $!level,
    $mode // $!mode,
    $casesensitive // $!casesensitive
  );
  return self;
}

method termplot(Int :$size)
{
  fail X::AdHoc.new: errno => 1, error => 'No data to plot' if ! $!qrcode.defined;
  my $s     = $size // $!size;
  my $w    := $!qrcode.width;
  my @data := $!qrcode.data;
  (@data[$_ * $w .. $_ * $w + $w - 1] »+&» 1)
    .join
    .trans('1' => "\c[FULL BLOCK]", '0' => ' ')
    .subst(/(.)/, {$0 x $s}, :g)
    .say
      for ^$w;
  return OK;
}

proto method get-data($dim?) {*}

multi method get-data(1)
{
  my $w    := $!qrcode.width;
  my @data := $!qrcode.data;
  @data[^($w * $w)] »+&» 1;
}

multi method get-data(2)
{
  my $w    := $!qrcode.width;
  my @data := $!qrcode.data;
  my @array[$w;$w] = [ for ^$w { @data[$_ * $w .. $_ * $w + $w - 1] »+&» 1 } ];
}

multi method get-data($dim?)
{
  fail 'non implemented';
}

submethod DESTROY
{
  QRcode_free($!qrcode) if $!qrcode.defined;
}

=begin pod

=head1 NAME

Image::QRCode - An interface to libqrencode.

=head1 SYNOPSIS
=begin code

use Image::QRCode;

my $code = Image::QRCode.new.encode('https://perl6.org/');
my $dim = $code.qrcode.width;
my @array2D[$dim;$dim] = $code.get-data(2);
say @array2D.shape;
say @array2D;
my @array1D = $code.get-data(1);
say @array1D;

=end code

=begin code

use Image::QRCode;

Image::QRCode.new.encode('https://perl6.org/').termplot;

=end code

For more examples see the I<example> directory.

=head1 DESCRIPTION

Image::QRCode provides an interface to libqrencode and allows you to generate a QR Code.

=head1 METHODS

=head2 new(Int :$.version, Int :$.level, Int :$.mode, Int :$.casesensitive, Int :$.size)

Creates an B<Image::QRCode> object. It may take a list of optional arguments.

The optional argument B<$version> defaults to 0 (auto-select). The maximum version value is 4.

The optional argument B<$level> defaults to QR_ECLEVEL_L. The list of possible values for this argument is
provided by the B<QRecLevel> enum:

=item QR_ECLEVEL_L  # lowest
=item QR_ECLEVEL_M
=item QR_ECLEVEL_Q
=item QR_ECLEVEL_H  # highest

The optional argument B<$mode> defaults to QR_MODE_8. The list of possible values for this argument is
provided by the B<QRencodeMode> enum:

=item QR_MODE_NUL        # Terminator (NUL character). Internal use only
=item QR_MODE_NUM        # Numeric mode
=item QR_MODE_AN         # Alphabet-numeric mode
=item QR_MODE_8          # 8-bit data mode
=item QR_MODE_KANJI      # Kanji (shift-jis) mode
=item QR_MODE_STRUCTURE  # Internal use only
=item QR_MODE_ECI        # ECI mode
=item QR_MODE_FNC1FIRST  # FNC1, first position
=item QR_MODE_FNC1SECOND # FNC1, second position

The optional argument B<$casesensitive> defaults to True.

The optional argument B<$size> defaults to 2. This argument is used only when generating a character based
plot of the QR code to adjust the relative proportion of width vs. height.

All these arguments can be accessed directly for both reading and writing:

=begin code

my Image::QRCode $code .= new;
$code.casesensitive = False;

=end code

=head2 encode(Str $text!, Int :$version, Int :$level, Int :$mode, Int :$casesensitive)

Encodes a string. It takes one I<mandatory> argument:
B<text>, the string to encode. All the other arguments are optional.

This method put a QR code in the attribute B<qrcode>, an object of class QRcode, which can be read directly or
managed by other methods.

The class B<QRcode> is an interface to the library's internal structure of a QR code. It has three attributes:

=item int32 $.version
=item int32 $.width
=item CArray[uint8] $.data

Even if the B<data> attribute can be accessed directly, its representation is a bit complex and most of the
coded information is not very useful.
The original library's documentation goes as follows:

=begin code

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

=end code

=item2 get-data($dimension)

This method returns the QR code data, encoded as a 1D or 2D array. The argument B<dimension> can be 1 or 2:
passing a dimension = 1 the method returns a linear array of the values of all the dots, coded as 0 (black)
or 1 (white).
A value of 2 makes the method return an array of arrays.

=item2 termplot(Int :$size)

This method accepts the optional parameter B<size>, which determines the orizontal stretch of the "image".
It prints the QR code on the terminal screen as C<\c[FULL BLOCK]> characters.
It returns a Failure object if there's no data to plot.

=head1 LOW LEVEL CALLS

This module provides an interface to all the C library's functions.
The library's full documentation can be found here:

L<https://fukuchi.org/works/qrencode/manual/index.html>

Its GitHub page is:

L<https://github.com/fukuchi/libqrencode>

=head1 Prerequisites

This module requires the libqrencode3 library to be installed. Please follow the
instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libqrencode3
=end code

=head1 Installation

=begin code
$ zef install Image::QRCode
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
