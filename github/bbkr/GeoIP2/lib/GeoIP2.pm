unit class GeoIP2:auth<bbkr>:ver<1.0.0>;

# only for IEEE conversions
use NativeCall;

# debug flag,
# can be turned  on and off at any time
has Bool $.debug is rw;

# database informations
has Version     $.binary-format-version;
has DateTime    $.build-timestamp;
has Str         $.database-type;
has             %!descriptions;
has Version     $.ip-version;
has Int         $.ipv4-start-node;
has Set         $.languages;
has Int         $.node-byte-size;
has Int         $.node-count;
has Int         $.record-size;
has Int         $.search-tree-size;

# *.mmdb file decriptor
has IO::Handle $!handle;

class X::PathInvalid is Exception is export { };
class X::MetaDataNotFound is Exception is export { };
class X::NodeIndexOutOfRange is Exception is export { };
class X::IPFormatInvalid is Exception is export { };

submethod BUILD ( Str:D :$path!, :$!debug = False ) {
    
    X::PathInvalid.new.throw( ) unless $path.IO ~~ :e & :f & :r;
    
    $!handle = open( $path, :bin );
    
    # extract metdata to confirm file is valid-ish
    with self!read-metadata( ) {
        $!binary-format-version = Version.new(
            .{ 'binary_format_major_version', 'binary_format_minor_version' }.join( '.' )
        );
        $!build-timestamp   = DateTime.new( .{ 'build_epoch' } );
        $!database-type     = .{ 'database_type' };
        %!descriptions      = .{ 'description' };
        $!ip-version        = Version.new( .{ 'ip_version' } );
        $!languages         = .{ 'languages' }.map( { .uc } ).Set;
        $!node-count        = .{ 'node_count' };
        $!record-size       = .{ 'record_size' };
    }
    
    # precalculate derived values for better performance
    $!node-byte-size    = ( $!record-size * 2 / 8 ).Int;
    $!search-tree-size  = $!node-count * $!node-byte-size;
    $!ipv4-start-node   = 0;
    if $!ip-version ~~ v6 {
        # for IPv4 in IPv6 subnet /96 contains 0s
        # so left node branch should be traversed 96 times
        for ^96 {
            ( $!ipv4-start-node,  ) = self!read-node( index => $!ipv4-start-node );
            last if $!ipv4-start-node >= $!node-count;
        }
    }
}

#| return description in requested language ( if available )
method description ( Str:D :$language = 'EN' ) {

    return %!descriptions{ $language.lc };
}

# locate IPv4 in dotted decimal notation
multi method locate ( Str:D :$ip! where / ^ ( [ \d ** 1..3 ] ) ** 4 % '.' $ / ) {
    my @bits;
    
    for $/[0] -> Int( ) $octet {
        
        X::IPFormatInvalid.new( message => $ip ).throw( ) if $octet > 255;
                
        # convert decimal to bits and append to flat bit array
        push @bits, |$octet.polymod( 2 xx 7 ).reverse( );
    }
    
    return self!read-ip( :@bits, index => $.ipv4-start-node );
}

# locate IPv6 in hexadecimal notattion
multi method locate ( Str:D :$ip! where / ^ ( [ <.xdigit> ** 1..4 ] ) ** 8 % ':' $ / ) {
    my @bits;
    
    for $/[0] -> Str( ) $hextet {
        
        # convert hexadecimal to bits and append to flat bit array
        push @bits, |:16( $hextet ).polymod( 2 xx 15 ).reverse( );
    }
    
    return self!read-ip( :@bits );
}

# find IP in binary tree and return geolocation info
method !read-ip ( :@bits!, :$index is copy = 0 ) {
    
    self!debug( :@bits ) if $.debug;
    
    for @bits -> $bit {
        
        # end of index or data pointer reached
        last if $index >= $!node-count;

        # check which branch of binary tree should be traversed
        my ( $left-pointer, $right-pointer ) = self!read-node( :$index );
        $index = $bit ?? $right-pointer !! $left-pointer;

        self!debug( :$index, :$bit ) if $.debug;
        
    }
    
    # IP not found
    return if $index == $!node-count;
    
    # position cursor to data section pointed by pointer
    $!handle.seek( $index - $!node-count + $!search-tree-size );
    
    return self!read-data( );
}

#| extract metadata information
method !read-metadata ( ) returns Hash {

    # constant sequence of bytes that separates IP data from metadata
    state $metadata-marker = Buf.new( 0xAB, 0xCD, 0xEF ) ~ 'MaxMind.com'.encode( );

    # position cursor after last occurrence of marker
    loop {
        
        # jump to EOF
        FIRST $!handle.seek( 0, SeekFromEnd );
        
        # check if BOF is reached before marker is found
        X::MetaDataNotFound.new.throw unless $!handle.tell > 0;
        
        # read one byte backwards
        $!handle.seek( -1, SeekFromCurrent );
        my $byte = $!handle.read( 1 )[ 0 ];
        $!handle.seek( -1, SeekFromCurrent );
        
        # not a potential marker start, try next byte
        next unless $byte == 0xAB;
        
        # marker found, cursor will be positioned right after it
        last if $!handle.read( $metadata-marker.elems ) == $metadata-marker;
        
        # marker not found, rewind cursor to previous position
        $!handle.seek( -$metadata-marker.elems, SeekFromCurrent );
    }
    
    # decode metadata section into map structure
    return self!read-data( );
}

#| return two pointers for left and right tree branch
method !read-node ( Int:D :$index! ) returns List {
    my ( $left-pointer, $right-pointer );
    
    # negative or too big index cannot be requested
    X::NodeIndexOutOfRange.new( message => $index ).throw( )
        unless 0 <= $index < $!node-count;

    # position cursor at the beginnig of node index
    $!handle.seek( $index * $!node-byte-size, SeekFromBeginning );
    
    given $!record-size {
    
        when 24 {
            
            # read two 24 bit pointers
            $left-pointer = self!read-unsigned-integer( size => 3 );
            $right-pointer = self!read-unsigned-integer( size => 3 );
            
        }
        when 28 {
            
            # bits 27...24 are taken from middle byte
            $left-pointer = self!read-unsigned-integer( size => 3 );
            my $middle-byte = $!handle.read( 1 )[ 0 ];
            $right-pointer = self!read-unsigned-integer( size => 3 );
            
            $left-pointer += ( $middle-byte +> 4 ) +< 24;
            $right-pointer += ( $middle-byte +& 0x0F ) +< 24;
            
        }
        when 32 {
            
            # read two 32 bit pointers
            $left-pointer = self!read-unsigned-integer( size => 4 );
            $right-pointer = self!read-unsigned-integer( size => 4 );
            
        }
        default {
            X::NYI.new( feature => 'Record size ' ~ $!record-size ).throw( );
        }
    
    }
    
    self!debug( :$left-pointer, :$right-pointer ) if $.debug;
    
    return $left-pointer, $right-pointer;
}

#| decode value at current handle position
method !read-data ( ) {
    my $out;
    
    # first byte is control byte
    my $control-byte = $!handle.read( 1 )[ 0 ];
    
    # right 3 bits of control byte describe container type
    my $type = $control-byte +> 5;
    self!debug( :$type ) if $.debug;
    
    # for pointers data is not located immediately after current cursor position
    if $type == 1 {
        
        # find location of remote data
        my $remote-cursor = self!read-pointer( :$control-byte );
        
        # remember current cursor position
        # to restore it after pointer jump
        my $current-cursor = $!handle.tell( );
        
        # decode data from remote location in file
        $!handle.seek( $remote-cursor, SeekFromBeginning );
        $out = self!read-data( );
        
        # return from pointer jump
        $!handle.seek( $current-cursor, SeekFromBeginning );
        
        return $out;
    }
    
    # extended type will map to type described by next byte
    if $type == 0 {
        $type = $!handle.read( 1 )[ 0 ] + 7;
        self!debug( :$type ) if $.debug;
    }
    
    my $size = self!read-size( :$control-byte );
    self!debug( :$size ) if $.debug;
    
    given $type {
        when 2 { $out = self!read-string( :$size ) }
        when 5 | 6 | 9 | 10 { $out = self!read-unsigned-integer( :$size ) }
        when 8 { $out = self!read-signed-integer( :$size ) }
        when 3 | 15 { $out = self!read-floating-number( :$size ) }
        when 14 { $out = self!read-boolean( :$size ) }
        when 11 { $out = self!read-array( :$size ) }
        when 7 { $out = self!read-hash( :$size ) }
        when 4 { $out = self!read-raw-bytes( :$size ) }
        default {
            X::NYI.new( feature => 'Value type ' ~ $type ).throw( )
        }
    }
    self!debug( data => $out ) if $.debug;
    
    return $out;
}

method !read-pointer ( Int:D :$control-byte! ) returns Int {
    my $pointer;
    
    # constant sequence of bytes that separates nodes from data
    state $data-marker = Buf.new( 0x00 xx 16 );
    
    # calculate pointer type
    # located on bits 4..3 of control byte
    my $type = ( $control-byte +& 0b00011000 ) +> 3;
    
    # for "small" pointers bits 2..0 of control byte are used
    # and then following bytes
    if $type ~~ 0 | 1 | 2 {
        $pointer = ( $control-byte +& 0b00000111 ) +< ( ( $type + 1 ) * 8 );
        $pointer += self!read-unsigned-integer( size => $type + 1 );
    }
    # for "big" pointer control byte bits are ignored
    # pointer is constructed entirely from following bytes
    else {
        $pointer = self!read-unsigned-integer( size => $type + 1 );
    }
    
    # some types have fixed value added
    given $type {
        when 1 { $pointer += 2048 }
        when 2 { $pointer += 526336 }
    }        
    
    # pointer starts at beginning of data section
    $pointer += $!search-tree-size + $data-marker.bytes;
    
    self!debug( :$pointer ) if $.debug;
    
    return $pointer;
}

#| check how big is next data chunk
method !read-size ( Int:D :$control-byte! ) returns Int {

    # last 5 bits of control byte describe container size
    my $size = $control-byte +& 0b00011111;
    
    # size could be stored entirely within control byte
    return $size if $size < 29;

    # size is stored in next bytes
    given $size {
        when 29 { return 29 + $!handle.read( 1 )[ 0 ] };
        when 30 { return 285 + self!read-unsigned-integer( size => 2 ) };
        default { return 65821 + self!read-unsigned-integer( size => 4 ) }
    }
}

method !read-string ( Int:D :$size! ) returns Str {
    
    return '' unless $size;
    return $!handle.read( $size ).decode( );
}

method !read-unsigned-integer ( Int:D :$size! ) returns Int {
    my $out = 0;
    
    # zero size means value 0
    return $out unless $size;
    
    for $!handle.read( $size ) -> $byte {
        $out +<= 8;
        $out +|= $byte;
    }
    
    return $out;
}

method !read-signed-integer ( Int:D :$size! ) returns Int {
    my $out = 0;
    
    # empty size means 0 value
    return $out unless $size;
    
    # negative numbrs are given in two's complement format
    # but only when all 4 bytes are given leftmost bit decides about sign -
    # otherwise zero padding is assumed and integer is positive
    return self!read-unsigned-integer( :$size ) if $size < 4;
    
    my $bytes = $!handle.read( $size );
    
    my $sign;
    if $bytes[0] +& 0b10000000 == 128 {
        $sign = -1;
    }
    else {
        $sign = 1;
    }

    for $bytes.list -> $byte {
        $out +<= 8;
        $out +|= $sign == 1 ?? $byte !! $byte +^ 0b11111111;
    }

    return $out if $sign == 1;
    return -( $out + 1 );
}

method !read-floating-number ( Int:D :$size! ) {
    
    my $bytes = $!handle.read( $size );
    
    # native casting is used to convert Buf to IEEE format
    # so if local architecture does not match big endian file format
    # then byte order must be reversed
    state $is-little-endian = nativecast(
        CArray[ uint8 ], CArray[ uint32 ].new( 1 )
    )[ 0 ] == 0x01;
    $bytes .= reverse( ) if $is-little-endian;
    
    given $size {
        when 4 { return nativecast( Pointer[ num32 ], $bytes ).deref( ) }
        when 8 { return nativecast( Pointer[ num64 ], $bytes ).deref( ) }
        default {
            X::NYI.new( feature => 'IEEE754 of size ' ~ $size ).throw( )
        }
    }
}

method !read-boolean ( Int:D :$size! ) returns Bool {
    
    # non zero size means True,
    # there is no additional data required to decode value
    return $size.Bool;
}

method !read-array ( Int:D :$size! ) returns Array {
    my @out;
    
    for ^$size {
        my $value = self!read-data( );
        @out.push: $value;
    }

    return @out;
}

method !read-hash ( Int:D :$size! ) returns Hash {
    my %out;
    
    for ^$size {
        my $key = self!read-data( );
        my $value = self!read-data( );
        %out{ $key } = $value;
    }

    return %out;
}

method !read-raw-bytes ( Int:D :$size! ) returns Buf {
    
    return Buf.new unless $size;
    return $!handle.read( $size );
}

method !debug ( *%_ ) {
    %_{ 'offset' } = $!handle.defined ?? $!handle.tell( ) !! 'unknown';
    note %_.gist;
}
