use Digest::SHA256::Native;
use Test;

plan 1;

my $max = 2000;
my $evens = Channel.new;
my $odds = Channel.new;

my $p1 = start { for 1,3,5 ... $max { $odds.send(sha256-hex("$_")) } }
my $p2 = start { for 2,4,6 ... $max { $evens.send(sha256-hex("$_")) } }

await($p1,$p2);

my @computed = map { |( $odds.receive, $evens.receive ) }, 1..($max/2);
my @answers = [ 1..$max ].map({ sha256-hex("$_") });

is-deeply @computed, @answers, 'computed in parallel';

done-testing;
