use v6;

use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder {
    method build($dir) {
        my %vars = get-vars($dir);

        my $gsc_bin = (%*ENV<GSC> || q:x/which gsc-script/ || q:x/which gsc/).trim();
        my $gsc_ver = (qq:x/$gsc_bin -v/).trim();
        my $gsc_ver_int;
        if ($gsc_ver ~~ /(\d+)\.(\d+)\.(\d+)/) {
            $gsc_ver_int = ~$0 * 100000 + ~$1 * 1000 + ~$2;
        } 
        if (defined $gsc_ver_int) {
            %vars<GSC_VER> = $gsc_ver_int;
        } else {
            die "unable to determine gsc version";
        }

        %vars<GSC> = $gsc_bin;
        %vars<LIBS> = %*ENV<LIBS> || '-lgambc';
        %vars<MYEXTLIB> = %*ENV<MYEXTLIB> || '';
        %vars<gambithelper> = $*VM.platform-library-name('gambithelper'.IO);
        say %vars;

        mkpath "$dir/resources/libraries";

        %*ENV<GAMBCOMP_VERBOSE> = 1;

        process-makefile('.', %vars);

        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);
    }
}

