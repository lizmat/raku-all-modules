use v6;
use Native::Resources::Build;

class Build {
    method build($workdir) {
        mkdir 'resources';
        mkdir 'resources/lib';
        make($workdir, "$workdir/resources/lib", :libname<numpack>);
    }

    # Only needed for panda compatability
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
