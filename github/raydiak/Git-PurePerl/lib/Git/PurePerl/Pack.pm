unit class Git::PurePerl::Pack;
use Compress::Zlib;

has IO::Path $.filename;
has IO::Handle $.fh = self.filename.open: :bin;

my @TYPES = ( 'none', 'commit', 'tree', 'blob', 'tag', '', 'ofs_delta',
    'ref_delta' );
my $OBJ_NONE      = 0;
my $OBJ_COMMIT    = 1;
my $OBJ_TREE      = 2;
my $OBJ_BLOB      = 3;
my $OBJ_TAG       = 4;
my $OBJ_OFS_DELTA = 6;
my $OBJ_REF_DELTA = 7;

my $SHA1Size = 20;

#`[[[
sub all_sha1s {
    my ( $self, $want_sha1 ) = @_;
    return Data::Stream::Bulk::Array->new(
        array => [ $self->index->all_sha1s ] );
}
]]]

method unpack_object ($offset is copy) {
    my $obj_offset = $offset;
    my $fh         = self.fh;

    $fh.seek( $offset, 0 );
    my $c = $fh.read( 1 );
    $c = $c.unpack: 'C';

    my $size        = ( $c +& 0xf );
    my $type_number = ( $c +> 4 ) +& 7;
    my $type = @TYPES[$type_number] || fail "invalid type $type_number";

    my $shift = 4;
    $offset++;

    while ( ( $c +& 0x80 ) != 0 ) {
        $c = $fh.read( 1 );
        $c = $c.unpack: 'C';
        $size +|= ( ( $c +& 0x7f ) +< $shift );
        $shift  += 7;
        $offset += 1;
    }

    if ( $type eq 'ofs_delta' || $type eq 'ref_delta' ) {
        ( $type, $size, my $content )
            = self.unpack_deltified( $type, $offset, $obj_offset, $size );
        return ( $type, $size, $content );

    } elsif ( $type eq 'commit'
        || $type eq 'tree'
        || $type eq 'blob'
        || $type eq 'tag' )
    {
        my $content = self.read_compressed( $offset, $size );
        return ( $type, $size, $content );
    } else {
        fail "invalid type $type";
    }
}

method read_compressed ($offset, $size) {
    my $fh = $.fh;

    $fh.seek: $offset, 0;

    my $out = Buf.new;

    my $decompressor = Compress::Zlib::Stream.new;
    my $read = 0;
    while !$decompressor.finished {
        my $block = $fh.read: 4096;
        $read += $block.bytes;
        my $data = $decompressor.inflate: $block;
        die $data if $data ~~ Failure;
        $out ~= $data;
    }

    $fh.seek: ($offset + $read - $decompressor.bytes-left), 0;

    fail "$out.bytes() is not $size" unless $out.bytes == $size;

    return $out;
}

method unpack_deltified ($type is copy, $offset is copy, $obj_offset, $size) {
    my $fh = $.fh;

    my $base;

    $fh.seek( $offset, 0 );
    my $data= $fh.read( $SHA1Size );
    my $sha1 = $data.unpack: 'H*';

    if ( $type eq 'ofs_delta' ) {
        my $i           = 0;
        my $c           = $data.subbuf( $i, 1 ).unpack( 'C' );
        my $base_offset = $c +& 0x7f;

        while ( $c +& 0x80 ) != 0 {
            $c = substr( $data, ++$i, 1 ).unpack( 'C' );
            $base_offset++;
            $base_offset +<= 7;
            $base_offset +|= $c +& 0x7f;
        }
        $base_offset = $obj_offset - $base_offset;
        $offset += $i + 1;

        ( $type, $, $base ) = self.unpack_object($base_offset);
    } else {
        ( $type, $, $base ) = self.get_object($sha1);
        $offset += $SHA1Size;

    }

    my $delta = self.read_compressed( $offset, $size );
    my $new = self.patch_delta( $base, $delta );

    return ( $type, $new.bytes, $new );
}

method patch_delta ($base, $delta) {
    my ( $src_size, $pos ) = self.patch_delta_header_size( $delta, 0 );
    if ( $src_size != $base.bytes ) {
        fail "invalid delta data";
    }

    ( my $dest_size, $pos ) = self.patch_delta_header_size( $delta, $pos );
    my $dest = Buf.new;

    while ( $pos < $delta.bytes ) {
        my $c = $delta.subbuf( $pos, 1 );
        $c = $c.unpack( 'C' );
        $pos++;
        if ( ( $c +& 0x80 ) != 0 ) {

            my $cp_off  = 0;
            my $cp_size = 0;
            $cp_off = $delta.subbuf($pos++, 1).unpack( 'C' )
                if ( $c +& 0x01 ) != 0;
            $cp_off +|= $delta.subbuf($pos++, 1).unpack( 'C' ) +< 8
                if ( $c +& 0x02 ) != 0;
            $cp_off +|= $delta.subbuf($pos++, 1).unpack( 'C' ) +< 16
                if ( $c +& 0x04 ) != 0;
            $cp_off +|= $delta.subbuf($pos++, 1).unpack( 'C' ) +< 24
                if ( $c +& 0x08 ) != 0;
            $cp_size = $delta.subbuf($pos++, 1).unpack( 'C' )
                if ( $c +& 0x10 ) != 0;
            $cp_size +|= $delta.subbuf($pos++, 1).unpack( 'C' ) +< 8
                if ( $c +& 0x20 ) != 0;
            $cp_size +|= $delta.subbuf($pos++, 1).unpack( 'C' ) +< 16
                if ( $c +& 0x40 ) != 0;
            $cp_size = 0x10000 if $cp_size == 0;

            $dest ~= $base.subbuf: $cp_off, $cp_size;
        } elsif ( $c != 0 ) {
            $dest ~= $delta.subbuf: $pos, $c;
            $pos += $c;
        } else {
            fail 'invalid delta data';
        }
    }

    if ( $dest.bytes != $dest_size ) {
        fail 'invalid delta data';
    }
    return $dest;
}

method patch_delta_header_size ($delta, $pos is copy) {
    my $size  = 0;
    my $shift = 0;
    loop {

        my $c = $delta.subbuf: $pos, 1;
        unless ( defined $c ) {
            fail 'invalid delta header';
        }
        $c = $c.unpack( 'C' );

        $pos++;
        $size +|= ( $c +& 0x7f ) +< $shift;
        $shift += 7;
        last if ( $c +& 0x80 ) == 0;
    }
    return ( $size, $pos );
}

# vim: ft=perl6
