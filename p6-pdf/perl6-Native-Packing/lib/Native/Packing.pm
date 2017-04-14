use v6;
use NativeCall;
use NativeCall::Types;

=begin pod

=head1 NAME

Native::Packing

=head1 DESCRIPTION

This module provides a role for serialization as simple binary
structs. At this stage, only simple native integer and numeric
types are supported.

Any class applying this role should contain only simple numeric
types, tha represent the structure of the data.

=head1 EXAMPLE

    use v6;
    use Native::Packing :Endian;

    # open a GIF read the 'screen' header
    my class GifScreenStruct
        does Native::Packing[Endian::Vax] {
        has uint16 $.width;
        has uint16 $.height;
        has uint8 $.flags;
        has uint8 $.bgColorIndex;
        has uint8 $.aspect;
    }

    my $fh = "t/lightbulb.gif".IO.open( :r :bin);
    $fh.read(6);  # skip GIF header

    my GifScreenStruct $screen .= read: $fh;

    say "GIF has size {$screen.width} X {$screen.height}";

=head1 METHODS

=head2 unpack(buf8)

Class level method. Unpack bytes from a buffer. Create a struct object.

=head2 pack

Object level method. Serialize the object to a buffer.

=head2 read(fh)

Class level method. Read data from a binary file. Create an object.

=head2 write(fh)

Object level method. Write the object to a file

=head2 bytes

Determine the overall size of the struct. Sum of all its attributes.

=head2 host-endian

Return the endian of the host Endian::Network(0) or Endian::Vax(1).

=end pod

my enum Native::Packing::Endian is export(:Endian) <Network Vax Host>;

role Native::Packing {
    my constant HostIsNetworkEndian = do {
        my $i = CArray[uint16].new(0x1234);
        my $j = nativecast(CArray[uint16], $i);
        $i[0] == 0x12;
    }

    my constant HostEndian = HostIsNetworkEndian
        ?? Network !! Vax;

    method host-endian {
        HostEndian
    }

    multi sub unpack-foreign-attribute($type, Buf $buf, uint $off is rw) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my buf8 $native .= new: $buf.subbuf($off, $byte-count).reverse;
        $off += $byte-count;
        my $cval = nativecast(CArray[$type], $native);
        $cval[0];
    }

    # convert between differing architectures
    method unpack-foreign(\buf) {
        # ensure we're working at the byte level
        my uint $off = 0;
        my %args = self.^attributes.map: {
            my $type = .type;
            my str $name = .name.substr(2);
            $name => unpack-foreign-attribute($type, buf, $off);
        }
        self.new(|%args);
    }

    multi sub read-foreign-attribute($type, \fh) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my $native = CArray[uint8].new: fh.read($byte-count).reverse;
        my $cval = nativecast(CArray[$type], $native);
        $cval[0];
    }

    # convert between differing architectures
    method read-foreign(\fh) {
        # ensure we're working at the byte level
        my %args = self.^attributes.map: {
            my str $name = .name.substr(2);
            my $type = .type;
           
            $name => read-foreign-attribute($type, fh);
        }
        self.new(|%args);
    }

    multi sub unpack-host-attribute($type, Buf $buf, uint $off is rw) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my Buf $raw = $buf.subbuf($off, $byte-count);
        my $cval = nativecast(CArray[$type], $raw);
        $off += $byte-count;
        $cval[0];
    }

    # matching architecture - straight copy
    method unpack-host(\buf) {
        # ensure we're working at the byte level
        my uint $off = 0;
        my %args = self.^attributes.map: {
            my str $name = .name.substr(2);
            my $type = .type;
            $name => unpack-host-attribute($type, buf, $off);
        }
        self.new(|%args);
    }

    multi sub read-host-attribute($type, \fh) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my buf8 $raw = fh.read( $byte-count);
        my $cval = nativecast(CArray[$type], $raw);
        $cval[0];
    }

    # matching architecture - straight copy
    method read-host(\fh) {
        # ensure we're working at the byte level
        my %args = self.^attributes.map: {
            my str $name = .name.substr(2);
            my $type = .type;
            $name => read-host-attribute($type, fh);
        }
        self.new(|%args);
    }

    multi sub pack-foreign-attribute($type, Buf $buf, $val) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my $cval = CArray[$type].new;
        $cval[0] = $val;
        my $bytes = nativecast(CArray[uint8], $cval);
        loop (my int $i = 1; $i <= $byte-count; $i++) {
            $buf.append: $bytes[$byte-count - $i];
        }
    }

    # convert between differing architectures
    method pack-foreign {
        # ensure we're working at the byte level
        my buf8 $buf .= new;
        my uint $off = 0;
        for self.^attributes {
            my $val = .get_value(self);
            pack-foreign-attribute(.type, $buf,  $val);
        }
        $buf;
    }

    # convert between differing architectures
    method write-foreign($fh) {
        $fh.write: self.pack-foreign;
    }

    multi sub pack-host-attribute($type, Buf $buf, $val) is default {
        my uint $byte-count = $type.^nativesize div 8;
        my $cval = CArray[$type].new;
        $cval[0] = $val;
        my $bytes = nativecast(CArray[uint8], $cval);
        loop (my int $i = 0; $i < $byte-count; $i++) {
            $buf.append: $bytes[$i];
        }
    }

    method pack-host {
        # ensure we're working at the byte level
        my buf8 $buf .= new;
        my uint $off = 0;
        for self.^attributes {
            my $val = .get_value(self);
            pack-host-attribute(.type, $buf,  $val);
        }
        $buf;
    }

    # convert between differing architectures
    method write-host($fh) {
        $fh.write: self.pack-host;
    }

    method bytes {
        [+] self.^attributes.map: *.type.^nativesize div 8;
    }
}

role Native::Packing[Native::Packing::Endian $endian]
    does Native::Packing {

    method unpack(\buf) {
        $endian == self.host-endian | Host
            ?? self.unpack-host(buf)
            !! self.unpack-foreign(buf)
    }

    method read(\fh) {
        $endian == self.host-endian | Host
            ?? self.read-host(fh)
            !! self.read-foreign(fh)
    }

    method pack {
        $endian == self.host-endian | Host
            ?? self.pack-host
            !! self.pack-foreign
    }

    method write(\fh) {
        $endian == self.host-endian | Host
            ?? self.write-host(fh)
            !! self.write-foreign(fh)
    }

}


