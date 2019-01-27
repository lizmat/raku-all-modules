use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
	my @tree = <
	  aaaa.txt
	  bbbb.txt
	  cccc/dddd.txt
	  cccc/eeee/ffff.txt
	  gggg.txt
	>;

	my @breadth = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  gggg.txt
	  cccc/dddd.txt
	  cccc/eeee
	  cccc/eeee/ffff.txt
	>;

	my @depth_pre = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  cccc/dddd.txt
	  cccc/eeee
	  cccc/eeee/ffff.txt
	  gggg.txt
	>;

	my @depth_post = <
	  aaaa.txt
	  bbbb.txt
	  cccc/dddd.txt
	  cccc/eeee/ffff.txt
	  cccc/eeee
	  cccc
	  gggg.txt
	  .
	>;

	my $td = make_tree(@tree);

	my $rule = Path::Finder;

	my @files = $rule.in($td, :order(BreadthFirst)).map: { unixify($_, $td) };
	is-deeply(@files, @breadth, "Breadth first iteration" );

	my @files2 = $rule.in($td, :order(PreOrder)).map: { unixify($_, $td) };
	is-deeply(@files2, @depth_pre, "Depth first iteration (pre)" );

	my @files3 = $rule.in($td, :order(PostOrder)).map: { unixify($_, $td) };
	is-deeply(@files3, @depth_post, "Depth first iteration (post)" );
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
