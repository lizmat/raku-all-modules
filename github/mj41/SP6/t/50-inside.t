use Test;
use SP6;

plan 1;

my $templ_dir = 't/templ';
my $sp6 = SP6.new( :templ_dir($templ_dir), );

is
	$sp6.process(:tfpath<inside.sp6>, :inside_tfpath<inside-outher.sp6>),
	'outherA main-text outherB',
	'inside';
