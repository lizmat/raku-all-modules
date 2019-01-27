use v6;
use Test;
use File::Temp;

use lib 't/lib';
use PFTest;

use Path::Finder :DEFAULT, :prune;

#--------------------------------------------------------------------------#

my @tree = <
  aaaa.txt
  bbbb.txt
  cccc/dddd.txt
  cccc/eeee/ffff.txt
  gggg.txt
>;

my $td = make_tree(@tree);

{
	my $rule = Path::Finder.or( Path::Finder.name("gggg.txt"), Path::Finder.name("bbbb.txt"));
	my @expected = <bbbb.txt gggg.txt>;

	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "or() test" );
}

{
	my $rule = Path::Finder.skip(Path::Finder.name("gggg.txt"), Path::Finder.name("cccc")).file;
	my @expected = < aaaa.txt bbbb.txt >;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "skip() test" );
}

{
	my $rule = Path::Finder.skip( sub ($item, *%) { return PruneExclusive if $item ~~ /eeee$/ } );
	my @expected = <
		  .
		  aaaa.txt
		  bbbb.txt
		  cccc
		  gggg.txt
		  cccc/dddd.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "skip() with custom rule" );
}

{
	my $rule = Path::Finder.skip( sub ($item, *%) { return PruneInclusive if $item ~~ /eeee$/ } );
	my @expected = <
		  .
		  aaaa.txt
		  bbbb.txt
		  cccc
		  gggg.txt
		  cccc/dddd.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "skip() with crazy custom rule" );
}

{
	my $rule = Path::Finder.skip( Path::Finder.skip-dir("eeee").name("gggg*") );
	my @expected = <
		  .
		  aaaa.txt
		  bbbb.txt
		  cccc
		  cccc/dddd.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "skip() with skip" )
}

{
	my $rule = Path::Finder.and(
		Path::Finder.none(
			Path::Finder.name("lldskfkad"), sub ($item, *%) { return PruneExclusive if $item ~~ /eeee$/ }
		)
	);
	my @expected = <
		  .
		  aaaa.txt
		  bbbb.txt
		  cccc
		  gggg.txt
		  cccc/dddd.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "none with references" );
}

{
	my $rule = Path::Finder.and(
		Path::Finder.or( sub ($item, *%) { return PruneExclusive if $item ~~ /eeee/ }, sub ($item, *%) { return True }, ),
		Path::Finder.and( sub ($item, *%){ $item ~~ /eeee/ } ),
	);
	my @expected = < cccc/eeee >;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "nested and + or with prunning" );
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
