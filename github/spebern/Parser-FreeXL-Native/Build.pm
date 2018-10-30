class Build {
    method build($workdir) {
        my $cwd = $*CWD.child('stub').absolute;
        try { ?shell("{$*VM.config<make>} distclean",         :$cwd) }
        try { ?shell("./configure --prefix={$*CWD.absolute}", :$cwd) }
        exit  ?shell("{$*VM.config<make>} install",           :$cwd)
            ?? 0
            !! 1;
    }

    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
