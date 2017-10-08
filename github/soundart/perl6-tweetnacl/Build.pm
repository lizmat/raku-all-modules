use v6;
use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
    method build($dir) {
        my %vars = get-vars($dir);
        %vars<tweetnacl> = $*VM.platform-library-name('tweetnacl'.IO);
        mkdir "$dir/resources" unless "$dir/resources".IO.e;
        mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;
        process-makefile($dir, %vars);
        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);
    }
}

# vim: ft=perl6
