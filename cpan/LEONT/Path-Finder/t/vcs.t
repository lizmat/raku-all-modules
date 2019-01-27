use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

my @tree = <<
  aaaa.txt
  bbbb.txt
  cccc/.svn/foo
  cccc/.bzr/foo
  cccc/.git/foo
  cccc/.hg/foo
  cccc/_darcs/foo
  cccc/CVS/foo
  cccc/RCS/foo
  eeee/foo,v
  "dddd/foo.#"
>>;

my $td = make_tree(@tree);

{
	my $rule     = Path::Finder.skip-vcs.file;
	my @expected = <
	  aaaa.txt
	  bbbb.txt
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "not_vcs test" );
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
