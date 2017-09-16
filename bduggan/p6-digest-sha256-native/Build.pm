use v6;
use LibraryMake;
use Shell::Command;

class Build {
    method build($dir) {
        my %vars = get-vars($dir);
        %vars<sha256> = $*VM.platform-library-name('sha256'.IO);
        mkdir "$dir/resources" unless "$dir/resources".IO.e;
        mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;
        process-makefile($dir, %vars);
        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);
    }
}

