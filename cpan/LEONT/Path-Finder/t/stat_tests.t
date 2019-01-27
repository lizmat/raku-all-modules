use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
	my $td = make_tree([<data/file1.txt>]);

	my $changes = $td.add('data/Changes');

	'Changes'.IO.copy($changes);

	my $rule = Path::Finder.file;

	my @files = $rule.in($td);
	is( @files.elems, 2, "Any file" ) or diag @files.perl;

	$rule  = Path::Finder.file.size(* > 0);
	@files = $rule.in($td);
	is( @files[0], $changes, "size > 0" ) or diag @files.perl;

}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
