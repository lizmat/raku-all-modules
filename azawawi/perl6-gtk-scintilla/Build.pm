
use v6;

unit class Build;

method build($work-dir) {
    my $make-file-dir = "$work-dir/src";
    my $dest-dir = "$work-dir/resources";
    $dest-dir.IO.mkdir;

    shell("cd $make-file-dir && make clean && make");
}

# only needed for older versions of panda
method isa($what) {
    return True if $what.^name eq 'Panda::Builder';
    callsame;
}
