use v6;
use LibraryMake;
use Shell::Command;

my $libname = 'tweetnacl';

class Build {
    method build($dir) {
        my %vars = get-vars($dir);
        %vars{$libname} = $*VM.platform-library-name($libname.IO);
        mkdir "$dir/resources" unless "$dir/resources".IO.e;
        mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;
        process-makefile($dir, %vars);
        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);
    }
}
