use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

my @tree = <
  aaaa.txt
  bbbb.txt
  cccc/dddd.txt
  cccc/eeee/ffff.txt
  gggg.txt
  hhhh/iiii/jjjj/kkkk/llll/mmmm.txt
>;

my $td = make_tree(@tree);

{
	my $rule  = Path::Finder.file.depth(3..*);
	my @expected = <
	  cccc/eeee/ffff.txt
	  hhhh/iiii/jjjj/kkkk/llll/mmmm.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @expected, "min_depth(3) test" );
}

{
	my $rule     = Path::Finder.depth(0..2).file;
	my @expected = <
	  aaaa.txt
	  bbbb.txt
	  gggg.txt
	  cccc/dddd.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @expected, "max_depth(2) test" );
}

{
	my $rule     = Path::Finder.file.depth(2..3);
	my @expected = <
	  cccc/dddd.txt
	  cccc/eeee/ffff.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @expected, "min_depth(2)->max_depth(3) test" );
}
done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
