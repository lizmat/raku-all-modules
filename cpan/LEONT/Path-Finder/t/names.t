use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

my @tree = <
  lib/Foo.pm
  lib/Foo.pod
  t/test.t
>;

my $td = make_tree(@tree);

{
	my $rule     = Path::Finder.name('Foo');
	my @expected = < >;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply(@got, @expected, "name('Foo') empty match");
}

{
	my $rule     = Path::Finder.name('Foo.*');
	my @expected = <
	  lib/Foo.pm
	  lib/Foo.pod
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "name('Foo.*') match" );
}

{
	my $rule     = Path::Finder.name(/Foo/);
	my @expected = <
	  lib/Foo.pm
	  lib/Foo.pod
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "name(qr/Foo/) match" );
}

{
	my $rule     = Path::Finder.name(rx:i/foo/);
	my @expected = <
	  lib/Foo.pm
	  lib/Foo.pod
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "name(qr/Foo/) match" );
}

{
	my $rule = Path::Finder.name("*.pod"|"*.pm");
	my @expected = <
	  lib/Foo.pm
	  lib/Foo.pod
	>;
	my @got = $rule.in($td).map: { unixify( $_, $td ) };
	is-deeply( @got, @expected, "name('*.pod', '*.pm') match" );
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
