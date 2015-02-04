use v6;
use Term::ProgressBar;

my $count = 100_000;

my $bar = Term::ProgressBar.new( count => $count, :p, :name<Uploading...>);

for 1..$count {
	$bar.update($_);
	$bar.message("$_") if $_ % 10000 == 0;
}
