use Test;
use SP6;

plan 1;

my $templ_dir = 't/templ';

my $sp6 = SP6.new( :templ_dir($templ_dir), );

is
	$sp6.process(:tfpath<vars-include.sp6>),
	'aabb< xx[42]yy[textB]zz >cc< 42+textB >dd',
	'vars include';
