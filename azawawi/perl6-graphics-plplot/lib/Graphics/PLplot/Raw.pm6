
use v6;

unit module Graphics::PLplot::Raw;

use NativeCall;

# Types:
# http://plplot.sourceforge.net/docbook-manual/plplot-html-5.12.0/c.html 


sub library {
    return "libplplotd.so";
}

sub plsdev(Str)
    is symbol('c_plsdev')
    is native(&library)
    is export { * }

sub plsfnam(Str)
    is symbol('c_plsfnam')
    is native(&library)
    is export { * }

sub plparseopts(Pointer, Pointer, int32) returns int32
    is symbol('c_plparseopts')
    is native(&library)
    is export { * }

sub plinit 
    is symbol('c_plinit')
    is native(&library)
    is export { * }

sub plgver(CArray[int8] is rw)
    is symbol('c_plgver')
    is native(&library)
    is export { * }

sub plenv(num64, num64, num64, num64, int32, int32)
    is symbol('c_plenv')
    is native(&library)
    is export { * }

sub pllab(Str, Str, Str)
    is symbol('c_pllab')
    is native(&library)
    is export { * }

sub plline(int32, CArray[num64], CArray[num64])
    is symbol('c_plline')
    is native(&library)
    is export { * }

sub plend
    is symbol('c_plend')
    is native(&library)
    is export { * }
