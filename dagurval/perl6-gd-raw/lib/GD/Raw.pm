use NativeCall;

sub LIB {
    given $*VM{'config'}{'load_ext'} {
        when '.so' { return 'libgd.so' }	# Linux
	    when '.bundle' { return 'libgd.dylib' }	# Mac OS
	    default { return 'libgd' }
    }
}

class gdImageStruct is repr('CStruct') is export {
    has int32 $.hack1; # Hack! don't know how to represent unsigned char **
    has int32 $.hack2; # Hack! so we pretend we have two ints to get to sx, sy
    has int32 $.sx = -1;
    has int32 $.sy = -1;
}

macro gdImageSX($img) is export {
    quasi { {{{$img}}}.sx };
}

macro gdImageSY($img) is export {
    quasi { {{{$img}}}.sy };
}

sub fopen( Str $filename, Str $mode )
    returns OpaquePointer
    is native(LIB) is export { ... }

sub fclose(OpaquePointer)
    is native(LIB) is export { ... }

sub gdImageCreateFromJpeg(OpaquePointer $file) 
    returns gdImageStruct
    is native(LIB) is export { ... } 

sub gdImageCreateFromPng(OpaquePointer $file) 
    returns gdImageStruct
    is native(LIB) is export { ... } 

sub gdImageCreateFromGif(OpaquePointer $file)
    returns gdImageStruct
    is native(LIB) is export { ... }

sub gdImageCreateFromBmp(OpaquePointer $file)
    returns gdImageStruct
    is native(LIB) is export { ... }

sub gdImageCreateTrueColor(int32, int32)
    returns gdImageStruct
    is native(LIB) is export { ... }

sub gdImageCreate(int32, int32)
    returns gdImageStruct
    is native(LIB) is export { ... }

sub gdImageJpeg(gdImageStruct $image, OpaquePointer $file, Int $quality where { $_ <= 95 }) 
    is native(LIB) is export { ... }

sub gdImagePng(gdImageStruct $image, OpaquePointer $file)
    is native(LIB) is export { ... }

sub gdImageGif(gdImageStruct $im, OpaquePointer $f)
    is native(LIB) is export { ... }

sub gdImageBmp(gdImageStruct $im, OpaquePointer $f, int32)
    is native(LIB) is export { ... }

sub gdImageCopyResized(gdImageStruct $dst, gdImageStruct $src, 
        int32 $dstX, int32 $dstY,
        int32 $srcX, int32 $srcY, 
        int32 $dstW, int32 $dstH, int32 $srcW, int32 $srcH) 
    is native(LIB) is export { ... }

sub gdImageCopyResampled(gdImageStruct $dst, gdImageStruct $src,
    Int $dstX, Int $dstY, Int $srcX, Int $srcY, Int $dstW, Int $dstH, Int $srcW, Int $srcH)
    is native(LIB) is export { ... }

sub gdImageDestroy(gdImageStruct)
    is native(LIB) is export { ... }

=begin pod

=head1 NAME

GD::Raw - Low level language bindings to GD Graphics Library

=head1 SYNOPSIS

    use GD::Raw;
    
    my $fh = fopen("my-image.png", "rb");
    my $img = gdImageCreateFromPng($fh);
    
    say "Image resolution is ", gdImageSX($img), "x", gdImageSX($img);
    
    gdImageDestroy($img);

=head1 DESCRIPTION

C<GD::Raw> is a low level language bindings to LibGD. It does not attempt to 
provide you with an perlish interface, but tries to stay as close to it's C 
origin as possible.

LibGD is large and this module far from covers it all. Feel free to add anything
your missing and submit a pull request!

=end pod
