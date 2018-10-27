use v6;
use Bench;
my $b = Bench.new;
my $buf = Buf.new(0 xx 1000);
my @values = $buf.list;

multi sub foo(@vals) { @vals.elems };
multi sub foo(*@vals) { foo(@vals) };

$b.timethese(1000, {
    list   => { my @li = $buf.list; foo(@li); },
    passli => { foo($buf.list) },
    passar => { foo(@values) },
});
