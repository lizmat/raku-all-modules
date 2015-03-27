use Git::PurePerl::Pack;
class Git::PurePerl::Pack::WithIndex is Git::PurePerl::Pack;
use Git::PurePerl::PackIndex;
use Git::PurePerl::PackIndex::Version1;
use Git::PurePerl::PackIndex::Version2;

has IO::Path $.index_filename is rw;
has Git::PurePerl::PackIndex $.index is rw;

submethod BUILD {
    my $index_filename = ~self.filename;
    $index_filename ~~ s/\.pack/.idx/;
    $index_filename .= IO;
    $!index_filename = $index_filename;

    my $index_fh = $index_filename.open: :bin;
    my $signature = $index_fh.read( 4 );
    my $version = $index_fh.read( 4 );
    $version = $version.unpack('N');
    $index_fh.close;

    if ( $signature.decode("latin-1") eq "\o377tOc" ) {
        if ( $version == 2 ) {
            $!index =
                Git::PurePerl::PackIndex::Version2.new(
                    filename => $index_filename
                );
        } else {
            fail("Unknown version");
        }
    } else {
        $!index =
            Git::PurePerl::PackIndex::Version1.new(
                filename => $index_filename
            );
    }
}

method get_object ($want_sha1) {
    my $offset = $.index.get_object_offset($want_sha1);
    return unless $offset;
    return self.unpack_object($offset);
}

# vim: ft=perl6
