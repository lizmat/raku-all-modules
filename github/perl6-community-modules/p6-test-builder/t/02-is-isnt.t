use lib <lib>;
use Test;
use Test::Builder;
use Test::Builder::Output;

plan 1;

my $grab := class :: is IO::Handle {
    has $.data = Buf.new;
    # old Rakudo's interface
    method write-internal(IO::Handle:D: Blob:D $buf --> True) {
        $!data.append: $buf
    }
    # new Rakudo's interface
    method WRITE(IO::Handle:D: Blob:D $buf --> True) { $!data.append: $buf }
}.new(path => $*SPEC.devnull).open: :w;

{
    temp $*OUT = $grab;
    temp $*ERR = $grab;
    with Test::Builder.new {
        .plan: *;
        .is:   43, 42, "`is` test 1";
        .is:   42, 42, "`is` test 2";
        .isnt: 43, 42, "`isn't` test 1";
        .isnt: 42, 42, "`isn't` test 2";
        .done;
    }
}

like $grab.data.decode, /
    «"not ok"» .+ "`is` test 1"    .+
    «ok»       .+ "`is` test 2"    .+
    «ok»       .+ "`isn't` test 1" .+
    «"not ok"» .+ "`isn't` test 2" .+
/, "is/isn't give right results";
