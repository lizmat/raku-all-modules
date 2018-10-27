use Bench;

my $b = Bench.new;

$b.timethese(1000, {
  first  => sub { sleep .05; },
  second => sub { sleep .005; },
});
'---------------------------------------------------------'.say;
$b.cmpthese(1000, {
  first  => sub { sleep .05; },
  second => sub { sleep .005; },
});
