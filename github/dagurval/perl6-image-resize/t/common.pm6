use v6;
use GD::Raw;

sub get-png-size($path) is export {
    my $fh = fopen($path, "rb") 
            or die "unable to open $path";
    my $img = gdImageCreateFromPng($fh) 
            or die "unable to read image $path";
    fclose($fh);
    my $x = gdImageSX($img);
    my $y = gdImageSY($img);
    gdImageDestroy($img);
    return $x, $y;
}

my @to-delete;
sub tmp-file($ext) is export {
    my $path = $*TMPDIR;
    $path = $path.child( ('a'..'z', 'A'..'Z').pick(10).join ~ ".$ext" );

    push @to-delete, $path;
    return $path.Str;
}

END {
    for @to-delete -> $d {
        try { unlink $d.Str }
    }
}
# vim: ft=perl6
