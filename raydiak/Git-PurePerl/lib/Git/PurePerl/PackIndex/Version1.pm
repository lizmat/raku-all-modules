use Git::PurePerl::PackIndex;
unit class Git::PurePerl::PackIndex::Version1 is Git::PurePerl::PackIndex;

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
    return 0;
}

method all_sha1s ($want_sha1) {
    my $fh = self.fh;
    my @sha1s;

    my $pos = $OffsetStart;
    $fh.seek( $pos, 0 );
    for 1 .. self.size -> $i {
        my $data = $fh.read( $OffsetSize );
        my $offset = $data.unpack( 'N' );
        $data = $fh.read( $SHA1Size );
        my $sha1 = $data.unpack( 'H*' );
        push @sha1s, $sha1;
        $pos += $EntrySize;
    }
    return @sha1s;
}

method get_object_offset ($want_sha1) {
    my @offsets = self.offsets;
    my $fh      = self.fh;

    my $slot = pack( 'H*', $want_sha1 ).unpack( 'C' );
    return unless defined $slot;

    my ( $first, $last ) = @offsets[ $slot, $slot + 1 ];

    while ( $first < $last ) {
        my $mid = ( ( $first + $last ) / 2 ).Int;
        $fh.seek( $SHA1Start + $mid * $EntrySize, 0 );
        my $data = $fh.read( $SHA1Size );
        my $midsha1 = $data.unpack( 'H*');
        if ( $midsha1 lt $want_sha1 ) {
            $first = $mid + 1;
        } elsif ( $midsha1 gt $want_sha1 ) {
            $last = $mid;
        } else {
            my $pos = $OffsetStart + $mid * $EntrySize;
            $fh.seek( $pos, 0 );
            my $data = $fh.read( $OffsetSize );
            my $offset = $data.unpack('N');
            return $offset;
        }
    }

    return;
}

# vim: ft=perl6
