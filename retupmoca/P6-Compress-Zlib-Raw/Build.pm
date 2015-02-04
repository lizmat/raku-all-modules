use Panda::Common;
use Panda::Builder;
use Inline;
use Shell::Command;

my sub longsize() is inline('C') returns Int {
'
DLLEXPORT int longsize() {
    return sizeof(long);
}
'
}

class Build is Panda::Builder {
    method build($workdir) {
        if longsize() < 8  {
            rm_f("$workdir/lib/Compress/Zlib/Raw.pm6");
            cp("$workdir/lib/Compress/Zlib/Raw.pm6.smallint", "$workdir/lib/Compress/Zlib/Raw.pm6");
            rm_f("$workdir/lib/Compress/Zlib/Raw.pm6.smallint");
        } else {
            rm_f("$workdir/lib/Compress/Zlib/Raw.pm6.smallint");
        }
    }
}