use v6;
use NativeCall;
use Test;

plan 1;

my sub malloc(size_t --> Pointer) is native() { * };

our sub FreeTry {
    my sub free(Pointer) is native() { * };
    my $p = malloc(10 * nativesizeof(uint8));
    say "Got $p";
    free($p);
}
lives-ok { FreeTry }, "NC works";
