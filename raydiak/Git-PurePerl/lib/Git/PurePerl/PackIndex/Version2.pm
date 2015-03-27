use Git::PurePerl::PackIndex;
class Git::PurePerl::PackIndex::Version2 is Git::PurePerl::PackIndex;

my $FanOutCount   = 256;
my $SHA1Size      = 20;
my $IdxOffsetSize = 4;
my $OffsetSize    = 4;
my $CrcSize       = 4;
my $OffsetStart   = $FanOutCount * $IdxOffsetSize;
my $SHA1Start     = $OffsetStart + $OffsetSize;
my $EntrySize     = $OffsetSize + $SHA1Size;
my $EntrySizeV2   = $SHA1Size + $CrcSize + $OffsetSize;

method global_offset {
    return 8;
}

method all_sha1s ($want_sha1) {
    my $fh = self.fh;
    my @sha1s;
    my @data;

    my $pos = $OffsetStart;
    $fh.seek( $pos + self.global_offset, 0 );
    for ^(self.size) -> $i {
        my $sha1 = $fh.read( $SHA1Size );
        @data[$i] = [ $sha1.unpack('H*'), 0, 0 ];
        $pos += $SHA1Size;
    }
    $fh.seek( $pos + self.global_offset, 0 );
    for ^(self.size) -> $i {
        my $crc = $fh.read( $CrcSize );
        @data[$i][1] = $crc.unpack( 'H*');
        $pos += $CrcSize;
    }
    $fh.seek( $pos + self.global_offset, 0 );
    for ^(self.size) -> $i {
        my $offset = $fh.read( $OffsetSize );
        @data[$i][2] = $offset.unpack('N');
        $pos += $OffsetSize;
    }
    for @data -> $data {
        my ( $sha1, $crc, $offset ) = @$data;
        push @sha1s, $sha1;
    }

    return @sha1s;
}

method get_object_offset ($want_sha1) {
    my @offsets = self.offsets;
    my $fh      = self.fh;

    my $slot = $want_sha1.pack( 'H*' ).unpack( 'C' );
    return unless defined $slot;

    my ( $first, $last ) = @offsets[ $slot, $slot + 1 ];

    while ( $first < $last ) {
        my $mid = ( ( $first + $last ) / 2 ).Int;

        $fh.seek( self.global_offset + $OffsetStart + ( $mid * $SHA1Size ) );
        my $data = $fh.read( $SHA1Size );
        my $midsha1 = $data.unpack('H*');
        if ( $midsha1 lt $want_sha1 ) {
            $first = $mid + 1;
        } elsif ( $midsha1 gt $want_sha1 ) {
            $last = $mid;
        } else {
            my $pos
                = self.global_offset 
                + $OffsetStart
                + ( self.size * ( $SHA1Size + $CrcSize ) )
                + ( $mid * $OffsetSize );
            $fh.seek( $pos, 0 );
            my $data = $fh.read( $OffsetSize );
            my $offset = $data.unpack('N');
            return $offset;
        }
    }
    return;
}

# vim: ft=perl6
