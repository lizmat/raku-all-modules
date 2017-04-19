perl6-Native-Packing
===============

## Description

Native::Packing is a simple solution for structured reading
and writing of binary numerical data.

## Example

```
use v6;
use Native::Packing :Endian;

# open a GIF read the header
my class LogicalDescriptor
    does Native::Packing[Endian::Vax] {

    has uint16 $.width;
    has uint16 $.height;
    has uint8  $.flags;
    has uint8  $.bgColorIndex;
    has uint8  $.aspect;
}

my $fh = "t/lightbulb.gif".IO.open( :r, :bin);
$fh.read(6);  # skip GIF header

my LogicalDescriptor $screen .= read: $fh;
say "GIF has size {$screen.width} X {$screen.height}";
```

It currently handles records containing native integers (int8, uint8, int16, etc) and
numerics (num32, num64).

- Data may read be and written to binary files, via the `read` and `write` methods

-  Or read and written to buffers via the `unpack` and `pack` methods.

## Endianess

The two fixed modes are:

- Vax (big endian) - least significant byte written first

- Network (little endian) - most significant byte written first

The endianess of the binary format needs to be known to correctly
read and write to it.

There is also a `Host` mode. This will read and write binary data in the
same endianess as the host computer.

Endian Examples:

```
use Native::Packing :Endian;
class C { has int16 $.a }
my $c = C.new: :a(42);
say ($c but Native::Packing[Vax]).pack;     # Buf[uint8]:0x<2a 00>
say ($c but Native::Packing[Network]).pack; # Buf[uint8]:0x<00 2a>
say ($c but Native::Packing[Host]).pack;    # Depends on your host

```

