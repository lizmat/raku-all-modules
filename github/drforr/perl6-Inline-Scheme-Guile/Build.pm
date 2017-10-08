use v6;
use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder
	{
	method build($dir)
		{
		my %vars = get-vars($dir);
		%vars<guile-helper> =
			$*VM.platform-library-name('guile-helper'.IO);
		mkdir "$dir/resources"
			unless "$dir/resources".IO.e;
		mkdir "$dir/resources/libraries"
			unless "$dir/resources/libraries".IO.e;
		process-makefile('.', %vars);

		my $goback = $*CWD;
		chdir($dir);
		shell(%vars<MAKE>);
		chdir($goback);
		}
	}

# vim: ft=perl6
