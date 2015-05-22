unit class Git::PurePerl::PackIndex;

has IO::Path $.filename = die "filename is required";
has IO::Handle $.fh is rw;
has @.offsets is rw;
has Int $.size is rw;

my $FanOutCount   = 256;
my $SHA1Size      = 20;
my $IdxOffsetSize = 4;
my $OffsetSize    = 4;
my $CrcSize       = 4;
my $OffsetStart   = $FanOutCount * $IdxOffsetSize;
my $SHA1Start     = $OffsetStart + $OffsetSize;
my $EntrySize     = $OffsetSize + $SHA1Size;
my $EntrySizeV2   = $SHA1Size + $CrcSize + $OffsetSize;

submethod BUILD (:$filename is copy) {
    $filename .= IO unless $filename ~~ IO::Path;
    $!filename = $filename;

    my $fh = $filename.open;
    $!fh = $fh;

    my @offsets = 0;
    $fh.seek( self.global_offset, 0 );
    for ^$FanOutCount -> $i {
        my $data = $fh.read($IdxOffsetSize);
        my $offset = $data.unpack( 'N' );
        fail("pack has discontinuous index") if $offset < @offsets[*-1];
        push @offsets, $offset;
    }
    @!offsets = @offsets;
    $!size = @offsets[*-1];
}

# vim: ft=perl6
