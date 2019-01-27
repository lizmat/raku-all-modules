use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
	my @tree = <
	  aaaa.txt
	  gggg.txt
	  cccc.txt
	  dddd.txt
	  bbbb.txt
	  eeee.txt
	>;

	my $td = make_tree(@tree);

	my @expected = $td.dir.map(*.basename);

	my $rule = Path::Finder.file;

	my @got = $rule.in($td, :!sorted).map: *.basename;
	is-deeply( @got, @expected, "unsorted gives disk order" )

}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
