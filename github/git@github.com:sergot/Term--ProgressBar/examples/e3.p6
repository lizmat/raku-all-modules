use v6;
use Term::ProgressBar;

my $count = 100_000;
my $bar = Term::ProgressBar.new( :left<:>, :right<:>, :style<.>, count => $count, :name<Testing..>, width => 50, :p, :t );

for 1..$count {
	$bar.update($_);
}
