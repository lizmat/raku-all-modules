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

	my @follow = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  gggg.txt
	  pppp
	  qqqq.txt
	  cccc/dddd.txt
	  cccc/eeee
	  pppp/ffff.txt
	>;

	my @not_loop_safe = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  gggg.txt
	  pppp
	  qqqq.txt
	  cccc/dddd.txt
	  cccc/eeee
	  pppp/ffff.txt
	  cccc/eeee/ffff.txt
	>;

	my @nofollow_report = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  gggg.txt
	  pppp
	  qqqq.txt
	  cccc/dddd.txt
	  cccc/eeee
	  cccc/eeee/ffff.txt
	>;

	my @nofollow_noreport = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  gggg.txt
	  cccc/dddd.txt
	  cccc/eeee
	  cccc/eeee/ffff.txt
	>;

	my $td = make_tree(@tree);

	symlink $td.add('cccc/eeee' ), $td.add('pppp');
	symlink $td.add('aaaa.txt' ), $td.add('qqqq.txt');

	my $rule = Path::Finder;

	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @follow, "Follow symlinks" );

	@got = $rule.in($td, :!loop-safe).map: { unixify( $_, $td ) };
	is-deeply(@got, @not_loop_safe, "Follow symlinks, but loop_safe = 0" );

	@got = $rule.in($td, :!follow-symlinks, :report-symlinks).map: { unixify( $_, $td ) };
	is-deeply(@got, @nofollow_report, "Don't follow symlinks, but report them" );

	@got = $rule.in($td, :!follow-symlinks, :!report-symlinks).map: { unixify( $_, $td ) };
	is-deeply(@got, @nofollow_noreport, "Don't follow or report symlinks" );

}

{
	my @tree = <
	  aaaa.txt
	  bbbb.txt
	  cccc/dddd.txt
	>;

	my $td = make_tree(@tree);

	symlink $td.add('zzzz' ), $td.add('pppp'); # dangling symlink
	symlink $td.add('cccc/dddd.txt' ), $td.add('qqqq.txt'); # regular symlink

	my @dangling = <
	  pppp
	>;

	my @not_dangling = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  qqqq.txt
	  cccc/dddd.txt
	>;

	my @valid_symlinks = <
	  qqqq.txt
	>;

	my $rule = Path::Finder.dangling;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @dangling, "Dangling symlinks" );

	$rule = Path::Finder.dangling(False);
	@got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @not_dangling, "No dangling symlinks" );

	$rule = Path::Finder.symlink.dangling(False);
	@got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @valid_symlinks, "Only non-dangling symlinks" )

}

{
	my @tree = <
	  aaaa.txt
	  bbbb.txt
	  cccc/dddd.txt
	>;

	my $td = make_tree(@tree);

	symlink $td.add('cccc'), $td.add('cccc/eeee' ); # symlink loop

	my @expected = <
	  .
	  aaaa.txt
	  bbbb.txt
	  cccc
	  cccc/dddd.txt
	  cccc/eeee
	>;

	my $rule = Path::Finder;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "Symlink loop" );
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
