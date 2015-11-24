use Panda::Common;
use Panda::Builder;
use LibraryMake;

class Build is Panda::Builder {
    method build($workdir) {
      my Str $os = qx[uname -s 2>/dev/null || echo not];
      if chomp($os) ~~ "FreeBSD" {
        shell("cd stub; gmake"); 
      } else { 
        shell("cd stub; make"); 
      }
    }
}
