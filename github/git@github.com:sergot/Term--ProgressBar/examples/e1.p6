use v6;
use Term::ProgressBar;

my $count = 100_000;
my $bar = Term::ProgressBar.new( count => $count, width => 50, :p );

for 1..$count {
	$bar.update($_);
}
