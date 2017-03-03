use Panda::Builder;

use Shell::Command;
use LWP::Simple;
use NativeCall;

class Build is Panda::Builder {
    method build($workdir) {
        # We only have a .dll file bundled on Windows; non-Windows is assumed
        # to have a libssh already.
        return unless $*DISTRO.is-win;

        my constant $file = "ssh.dll";
        my constant $hash = "E95FC7DD3F1B12B9A54B4141D4D63FB05455913660FA7EC367C560B9C244C84A";

        # to avoid a dependency (and because Digest::SHA is too slow), we do a hacked up powershell hash
        # this should work all the way back to powershell v1
        my &ps-hash = -> $path {
            my $fn = 'function get-sha256 { param($file);[system.bitconverter]::tostring([System.Security.Cryptography.sha256]::create().computehash([system.io.file]::openread((resolve-path $file)))) -replace \"-\",\"\" } ';
            my $out = qqx/powershell -noprofile -Command "$fn get-sha256 $path"/;
            $out.lines.grep({$_.chars})[*-1];
        }
        say 'Installing bundled libssh.';

        my $basedir = $workdir ~ '\resources';

        say "Fetching $file";
        my $blob = LWP::Simple.get("http://www.p6c.org/~jnthn/libssh/$file");
        say "Writing $file";
        spurt("$basedir\\$file", $blob);

        say "Verifying $file";
        my $got-hash = ps-hash("$basedir\\$file");
        if ($got-hash ne $hash) {
            die "Bad download of $file (got: $got-hash; expected: $hash)";
        }
    }
}
