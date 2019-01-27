use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
	my $td = make_tree([< data/file1.txt >]);

	my $file = $td.add('data/file1.txt' );
	# chmod a-rwx
	$file.chmod(:8('777'));

	my $rule  = Path::Finder.file;
	my @files = $rule.in($td);
	is(@files.elems, 1, "Any file");

	$rule  = Path::Finder.file.readable;
	@files = $rule.in($td);
	is(@files.elems, 1, "readable" );

	$rule  = Path::Finder.file.readable(False);
	@files = $rule.in($td);
	is(@files.elems, 0, "not_readable" );

}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
