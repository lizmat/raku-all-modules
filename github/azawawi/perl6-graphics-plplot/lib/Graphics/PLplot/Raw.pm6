
use v6;

unit module Graphics::PLplot::Raw;

use NativeCall;

# Types:
# http://plplot.sourceforge.net/docbook-manual/plplot-html-5.12.0/c.html 


sub library {
    return "libplplotd.so";
}

constant DRAW_LINEX is export  = 0x001; # Draw lines parallel to the X axis
constant DRAW_LINEY is export  = 0x002; # Draw lines parallel to the Y axis
constant DRAW_LINEXY is export = 0x003; # Draw lines parallel to both the X and
                                        # Y axis
constant MAG_COLOR is export   = 0x004; # Draw the mesh with a color dependent
                                        # of the
                                        # magnitude
constant BASE_CONT is export   = 0x008; # Draw contour plot at bottom xy plane
constant TOP_CONT is export    = 0x010; # Draw contour plot at top xy plane
constant SURF_CONT is export   = 0x020; # Draw contour plot at surface
constant DRAW_SIDES is export  = 0x040; # Draw sides
constant FACETED is export     = 0x080; # Draw outline for each square that
                                        # makes up the surface
constant MESH is export        = 0x100; # Draw mesh

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

sub plgver(CArray[int8])
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

sub plsori(int32)
    is symbol('c_plsori')
    is native(&library)
    is export { * }

sub plarc(num64, num64, num64, num64, num64, num64, num64, int32)
    is symbol('c_plarc')
    is native(&library)
    is export { * }

sub plcol0(int32)
    is symbol('c_plcol0')
    is native(&library)
    is export { * }

sub pljoin(num64, num64, num64, num64)
    is symbol('c_pljoin')
    is native(&library)
    is export { * }

sub plptex(num64, num64, num64, num64, num64, Str)
    is symbol('c_plptex')
    is native(&library)
    is export { * }


sub plmtex(Str, num64, num64, num64, Str)
    is symbol('c_plmtex')
    is native(&library)
    is export { * }

sub plssub(int32, int32)
    is symbol('c_plssub')
    is native(&library)
    is export { * }

sub plvpor(num64, num64, num64, num64)
    is symbol('c_plvpor')
    is native(&library)
    is export { * }

sub plwind(num64, num64, num64, num64)
    is symbol('c_plwind')
    is native(&library)
    is export { * }

sub plbox(Str, num64, int32, Str, num64, int32)
    is symbol('c_plbox')
    is native(&library)
    is export { * }

sub plwidth(num64)
    is symbol('c_plwidth')
    is native(&library)
    is export { * }

sub plschr(num64, num64)
    is symbol('c_plschr')
    is native(&library)
    is export { * }

sub plfont(int32)
    is symbol('c_plfont')
    is native(&library)
    is export { * }

sub plbop
    is symbol('c_plbop')
    is native(&library)
    is export { * }

sub pleop
    is symbol('c_pleop')
    is native(&library)
    is export { * }

sub pladv(int32)
    is symbol('c_pladv')
    is native(&library)
    is export { * }

sub plhlsrgb(num64, num64, num64, num64 is rw, num64 is rw, num64 is rw)
    is symbol('c_plhlsrgb')
    is native(&library)
    is export { * }

sub plgcol0(int32, int32 is rw, int32 is rw, int32 is rw)
    is symbol('c_plgcol0')
    is native(&library)
    is export { * }

sub plscmap0(CArray[int32], CArray[int32], CArray[int32], int32)
    is symbol('c_plscmap0')
    is native(&library)
    is export { * }

sub plbox3(Str, Str, num64, int32, Str, Str, num64, int32, Str, Str, num64,
        int32
    )
    is symbol('c_plbox3')
    is native(&library)
    is export { * }

sub plw3d(num64, num64, num64, num64, num64, num64, num64, num64, num64, num64,
        num64
    )
    is symbol('c_plw3d')
    is native(&library)
    is export { * }

sub plline3(int32, CArray[num64], CArray[num64], CArray[num64])
    is symbol('c_plline3')
    is native(&library)
    is export { * }

sub plstring3(int32, CArray[num64], CArray[num64], CArray[num64], Str)
    is symbol('c_plstring3')
    is native(&library)
    is export { * }

sub plpoly3(int32, CArray[num64], CArray[num64], CArray[num64], CArray[int32], int32)
    is symbol('c_plpoly3')
    is native(&library)
    is export { * }

sub plscmap1n(int32)
    is symbol('c_plscmap1n')
    is native(&library)
    is export { * }

sub plscmap1l(int32, int32, CArray[num64], CArray[num64], CArray[num64],
        CArray[num64], CArray[int32]
    )
    is symbol('c_plscmap1l')
    is native(&library)
    is export { * }

sub plmesh(CArray[num64], CArray[num64], CArray[CArray[num64]], int32, int32, int32)
    is symbol('c_plmesh')
    is native(&library)
    is export { * }

sub plot3d(CArray[num64], CArray[num64], CArray[CArray[num64]], int32, int32, int32,
        int32
    )
    is symbol('c_plot3d')
    is native(&library)
    is export { * }

sub plmeshc(CArray[num64], CArray[num64], CArray[CArray[num64]], int32, int32, int32,
        CArray[num64], int32
    )
    is symbol('c_plmeshc')
    is native(&library)
    is export { * }

sub plhist(int32, CArray[num64], num64, num64, int32, int32)
    is symbol('c_plhist')
    is native(&library)
    is export { * }
