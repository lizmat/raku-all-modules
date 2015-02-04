use Test;
use SP6;

plan 2;

my $templ_dir = 't/templ';

my $sp6 = SP6.new( :templ_dir($templ_dir), );

is
	$sp6.process(:tfpath<include.sp6>),
	'aa inner-text cc',
	'include';

is
	$sp6.process(:tfpath<include-line.sp6>),
	'aa line 1 itext-s (i-line 2) itext-e
cc
line 3
dd line 4 itext-s (i-line 2) itext-e
ee',
	'include line num';
