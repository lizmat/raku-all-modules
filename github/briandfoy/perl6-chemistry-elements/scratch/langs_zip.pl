#!/Users/brian/.rakudobrew/bin/perl6

my @array = < a b c d >
	==> map( { $_ => 1 } )
	==> my %hash1;

say %hash1.gist;

say '-' x 50;

my %hash2 = @array Z=> (0 .. *);
say %hash2.gist;

say '-' x 50;

my %hash3 = (my @array1 = < a b c d >) Z=> (0 ... *);
say %hash3.gist;

say '-' x 50;

my @langs = < pig en de >;
my %hash = @langs Z=> 1..*;

say %hash.gist;

say '-' x 50;

my $range := 1 .. *;
say ".. is > " ~ $range.^name;
say "\tmin " ~ $range.min;
say "\tmax " ~ $range.max;

my $list := 1 ... *;
say "... is > " ~ $list.^name;


for 1, 2, -> $a, $b { ( $a + $b ) % 5 } ... * -> $next {
	state $count = 1;
	say $next;
	last if $count++ > 20;
	}
