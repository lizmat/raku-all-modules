use v6;
use LWP::Simple;
use NativeCall;

class Build {
    method build($workdir) {
        # We only have a .dll file bundled on Windows; non-windows is assumed
        # to have a libarchive already.
        return unless $*DISTRO.is-win;

        my constant $file = "libarchive.dll";
        my constant $hash = "E6836E32802555593AEDAFE1CC00752CBDA0EBCE051500B1AA37847C30EFF161";

        # to avoid a dependency (and because Digest::SHA is too slow), we do a hacked up powershell hash
        # this should work all the way back to powershell v1
        my &ps-hash = -> $path {
            my $fn = 'function get-sha256 { param($file);[system.bitconverter]::tostring([System.Security.Cryptography.sha256]::create().computehash([system.io.file]::openread((resolve-path $file)))) -replace \"-\",\"\" } ';
            my $out = qqx/powershell -noprofile -Command "$fn get-sha256 $path"/;
            $out.lines.grep({$_.chars})[*-1];
        }
        say 'Installing bundled libarchive.';

        my $basedir = $workdir ~ '\resources';

        say "Fetching $file";
        my $blob = LWP::Simple.get("http://www.p6c.org/~jnthn/libarchive/$file");
        say "Writing $file";
        spurt("$basedir\\$file", $blob);

        say "Verifying $file";
        my $got-hash = ps-hash("$basedir\\$file");
        if ($got-hash ne $hash) {
            die "Bad download of $file (got: $got-hash; expected: $hash)";
        }
    }
}
