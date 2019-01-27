use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
	my ( $rule, @files );

	my $td = make_tree([<file1.txt>]);
	$td.add('file2.txt').spurt(map { "$_\n"}, <foo bar baz> );
	$td.add('file3.txt').spurt(<foo bar baz>);
	$td.add('file4.txt').spurt("\x[2603]");

	my @got = find($td, :file, :lines(/foo.*baz/)).map: { unixify( $_, $td ) };
	is-deeply(@got, ['file3.txt']);

	is-deeply(
		[ find($td, :file, :no-lines(/foo.*baz/)).map: { unixify( $_, $td ) } ],
		[qw/file1.txt file2.txt file4.txt/],
	);

	is-deeply(
        [ find($td, :file, :contents(/foo.*baz/)).map: { unixify( $_, $td ) } ],
		[qw/file2.txt file3.txt/],
	);

	is-deeply(
        [ find($td, :file, :contents(* !~~ /foo.*baz/)).map: { unixify( $_, $td ) } ],
		[qw/file1.txt file4.txt/],
	);

	# encoding stuff
	is-deeply(
        [ find($td, :file, :contents(/\x[2603]/)).map: { unixify( $_, $td ) } ],
		['file4.txt']
	);

	is-deeply(
        [ find($td, :file, :contents(\(/\x[2603]/, :enc<latin1>))).map: { unixify( $_, $td ) } ],
		[]
	);

	is-deeply(
        [ find($td, :file, :contents(\(/\x[E2]\x[98]\x[83]/, :enc<latin1>))).map: { unixify( $_, $td ) } ],
		['file4.txt']
	);

}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
