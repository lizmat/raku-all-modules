use Git::PurePerl::Pack;
use Digest::SHA;
class Git::PurePerl::Pack::WithoutIndex is Git::PurePerl::Pack;

has %.offsets is rw;

my @TYPES = ( 'none', 'commit', 'tree', 'blob', 'tag', '', 'ofs_delta',
    'ref_delta' );

method create_index {
    my $index_filename = ~self.filename;
    $index_filename ~~ s/\.pack/.idx/;
    my $index_fh = $index_filename.IO.open: :bin :w;

    my %offsets = self.create_index_offsets;
    my @fan_out_table;
    for %offsets.keys.sort -> $sha1 {
        my $offset = %offsets{$sha1};
        my $slot = pack( 'H*', $sha1 ).unpack( 'C' );
        @fan_out_table[$slot]++;
    }
    for ^256 -> $i {
        $index_fh.write: pack( 'N', @fan_out_table[$i] || 0 );
        @fan_out_table[ $i + 1 ] += @fan_out_table[$i] || 0;
    }
    for %offsets.keys.sort -> $sha1 {
        my $offset = %offsets{$sha1};
        $index_fh.write: pack( 'N',  $offset );
        $index_fh.write: pack( 'H*', $sha1 );
    }

    # read the pack checksum from the end of the pack file
    my $size = self.filename.Str.IO.s; # todo report caching problem
    my $fh   = $.fh;
    $fh.seek: $size - 20, 0;
    my $pack_sha1 = $fh.read: 20;

    $index_fh.write: $pack_sha1;
    $index_fh.close;
    my $digest = sha1 $index_filename.IO.slurp: :bin;
    $index_filename.IO.spurt: $digest, :append :bin;
}

method create_index_offsets {
    my $fh = $.fh;

    my $signature = $fh.read: 4;
    my $version = $fh.read: 4;
    $version = $version.unpack( 'N' );
    my $objects = $fh.read: 4;
    $objects = $objects.unpack( 'N' );

    my %offsets;
    %!offsets := %offsets;

    for 1 .. $objects -> $i {
        my $offset = $fh.tell;
        my $obj_offset = $offset;
        my $c= $fh.read: 1;
        $c = $c.unpack( 'C' );
        $offset++;

        my $size        = ( $c +& 0xf );
        my $type_number = ( $c +> 4 ) +& 7;
        my $type        = @TYPES[$type_number]
            || fail
            "invalid type $type_number at offset $offset, size $size";

        my $shift = 4;

        while ( ( $c +& 0x80 ) != 0 ) {
            $c = $fh.read: 1;
            $c = $c.unpack( 'C' );
            $offset++;
            $size +|= ( ( $c +& 0x7f ) +< $shift );
            $shift += 7;
        }

        my $content;

        if ( $type eq 'ofs_delta' || $type eq 'ref_delta' ) {
            ( $type, $size, $content )
                = self.unpack_deltified( $type, $offset, $obj_offset, $size);#, %offsets );
        } elsif ( $type eq 'commit'
            || $type eq 'tree'
            || $type eq 'blob'
            || $type eq 'tag' )
        {
            $content = self.read_compressed( $offset, $size );
        } else {
            fail "invalid type $type";
        }

        my $raw  = "$type $size\0".encode('latin-1') ~ $content;
        my $sha1_hex = sha1($raw).unpack: 'H*';
        %offsets{$sha1_hex} = $obj_offset;
    }

    return %offsets;
}

method get_object ($want_sha1) {
    my $offset = self.offsets{$want_sha1};
    return unless $offset;
    return self.unpack_object: $offset;
}

# vim: ft=perl6
