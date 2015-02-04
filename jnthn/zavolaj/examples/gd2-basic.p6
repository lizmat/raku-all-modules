# Call the GD graphics library that is also used by Perl 5's GD module.

use NativeCall;  # from project 'zavolaj'

# -------- foreign function definitions in alphabetical order ----------
sub gdImageCreate( Int $width, Int $height )
    returns OpaquePointer
    is native('libgd') { ... }

sub gdImageColorAllocate( OpaquePointer $image, Int $red, Int $green, Int $blue )
    returns Int
    is native('libgd') { ... }

sub gdImageLine( OpaquePointer $image, Int $x1, Int $y1, Int $x2, Int $y2, Int $colour )
    is native('libgd') { ... }

sub gdImagePng( OpaquePointer $image, OpaquePointer $file )
    is native('libgd') { ... }

sub gdImageJpeg( OpaquePointer $image, OpaquePointer $file, Int $quality )
    is native('libgd') { ... }

sub gdImageDestroy( OpaquePointer $image )
    is native('libgd') { ... }

sub fopen( Str $filename, Str $mode )
    returns OpaquePointer
    is native() { ... }

sub fclose( OpaquePointer $filepointer )
    is native() { ... }

# Translation of the example at http://www.libgd.org/Basics from C to
# Perl 6.  The only reason for having a MAIN subroutine is to have it
# look as similar as possible.
sub MAIN {
    # Declare the image
    my $im;
    # Declare output files
    my ($pngout, $jpegout);
    # Declare color indexes
    my Int $black;
    my Int $white;
    # Allocate the image: 64 pixels across by 64 pixels tall
    $im = gdImageCreate(64, 64);
    # Allocate the color black (red, green and blue all minimum).
    # Since this is the first color in a new image, it will
    # be the background color.
    $black = gdImageColorAllocate($im, 0, 0, 0);
 
    # Allocate the color white (red, green and blue all maximum).
    $white = gdImageColorAllocate($im, 255, 255, 255);
 
    # Draw a line from the upper left to the lower right,
    # using white color index.
    gdImageLine($im, 0, 0, 63, 63, $white);
 
    # Open a file for writing. "wb" means "write binary", important
    # under MSDOS, harmless under Unix.
    $pngout = fopen("test.png", "wb");
 
    # Do the same for a JPEG-format file.
    $jpegout = fopen("test.jpg", "wb");
 
    # Output the image to the disk file in PNG format.
    gdImagePng($im, $pngout);
 
    # Output the same image in JPEG format, using the default
    # JPEG quality setting.
    gdImageJpeg($im, $jpegout, -1);
 
    # Close the files.
    fclose($pngout);
    fclose($jpegout);
 
    # Destroy the image in memory.
    gdImageDestroy($im);
}

=begin pod

=head1 PREREQUISITES

The GD library must be installed installed.  On Debian systems such
as Ubuntu, install libgd-xpm-dev (or libgd-noxpm-dev) because Zavolaj
cannot find the variant without the -dev suffix.  This applies to most
libraries called by Zavolaj, and probably is caused by an implementation
detail within Parrot.

=head1 SEE ALSO

Official GD project home page: http://www.libgd.org

=end pod
