use Panda::Common;
use Panda::Builder;
use LibraryMake;

class Build is Panda::Builder {
    method build($workdir) {
        my Str $os = qx[uname -s 2>/dev/null || echo not];
        my $prefix_dir = IO::Path.new('.').absolute;
        if chomp($os) ~~ "FreeBSD" {
            shell("cd stub; ./configure --prefix=$prefix_dir; gmake install");
        }
        else {
            shell("cd stub; ./configure --prefix=$prefix_dir; make install");
        }
    }
}
