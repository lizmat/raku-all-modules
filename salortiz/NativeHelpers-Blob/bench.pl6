use v6;
use Bench;
use NativeHelpers::Blob;
use NativeCall;

#$NativeHelpers::Blob::debug = True;
my $b = Bench.new;

my $small = Buf.new(0 xx 100);
my $medium = Buf.new(0 xx 1000);
my $large = Buf.new(0 xx 10000);

say "Buf list";
$b.timethese(1000, {
    small => { my @c = $small.list },
    medium => { my @c = $medium.list },
    large => { my @c = $large.list }
});

say "Blob to Carray";
$b.timethese(1000, {
    empty    => { CArray[uint8].new },
    sml-clas => { CArray[uint8].new($small.list) },
    sml-fast => { carray-from-blob($small):managed; },
    med-clas => { CArray[uint8].new($medium.list) },
    med-fast => { carray-from-blob($medium):managed; },
    lge-clas => { CArray[uint8].new($large.list) },
    lge-fast => { carray-from-blob($large):managed; }
});

say "Blob creation";
my %tests = (
    clasic => { Blob.new(0 xx 10000) },
    fast   => { blob-allocate(Blob, 10000) }
);
%tests<alloc> = { Blob.allocate(10000) } if Blob.can('allocate');

$b.timethese(1000, %tests);

# vim: ft=perl6:sw=4:st=4
