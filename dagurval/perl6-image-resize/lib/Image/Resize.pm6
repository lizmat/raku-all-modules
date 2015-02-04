use GD::Raw;

module Image::Resize;

class Image::Resize {

    has Str $!img-path;
    has gdImageStruct $!src-img;


    method new(Cool $path) {

        die "File '$path' does not exist"
            unless $path.Str.IO.e;

        self.bless(*, img-path => $path);
    }

    submethod BUILD(:$!img-path) { 
        self!open-src();
    }

    multi method resize(Cool $dst-path, $factor,
        :$no-resample, :$jpeg-quality) {

        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);

        self.resize($dst-path, ($w * $factor).Int, ($h * $factor).Int, :$no-resample, :$jpeg-quality);
    }

    multi method resize(Cool $dst-path, 
            Int $new-width, Int $new-height,
            :$no-resample, :$jpeg-quality is copy) {
        
        $jpeg-quality //= -1;

        my $w = gdImageSX($!src-img);
        my $h = gdImageSY($!src-img);

        my $resized = gdImageCreateTrueColor($new-width, $new-height);
        die "Unable to create a resized image {$new-width}x{$new-height}"
            unless $resized;

        if $no-resample {
            gdImageCopyResized($resized, $!src-img, 0, 0, 0, 0, 
                    $new-width, $new-height, $w, $h)
        }
        else {
            gdImageCopyResampled($resized, $!src-img, 0, 0, 0, 0, 
                    $new-width, $new-height, $w, $h);
        } 
        
        self!save-img($resized, $dst-path, :$jpeg-quality);
        gdImageDestroy($resized);
        self;
    }


    method !get-ext($path) {
        $path.IO.path.basename ~~ /'.' (\w+)/;
        my Str $ext = ~$/[0];
        die "Path '$path' is missing image extension (.png, .jpg etc.)"
            unless $ext;
        
        die "Unsupported image extension '$ext' in $path"
            unless $ext.lc ~~ any <gif jpg jpeg png bmp>;

        return $ext.lc;
    }

    method !open-src {
        
        $!img-path or die "no image path";
        my $fh = fopen($!img-path, "rb")
            or die "unable to open $!img-path for reading";

        my $ext = self!get-ext($!img-path);
        my %ext-to-func = {
            bmp => &gdImageCreateFromBmp,
            jpg => &gdImageCreateFromJpeg,
            jpeg => &gdImageCreateFromJpeg,
            gif => &gdImageCreateFromGif,
            png => &gdImageCreateFromPng
        };
        
        {
            $!src-img = %ext-to-func{$ext}($fh) or {
                    fclose($fh);
                    die "unable to load $!img-path as $ext";
                }();
        }
        
        fclose($fh);
    }


    method !save-img($img, $dst-path, Int :$jpeg-quality!) {

        my $imgh = fopen($dst-path, "wb")
            or die "Unable top open '$img' for writing";

        my $ext = self!get-ext($dst-path);
        
        given ($ext) {
            when any <jpg jpeg> {
                gdImageJpeg($img, $imgh, $jpeg-quality);
            }
            when 'bmp' {
                gdImageBmp($img, $imgh, 0);
                CATCH { default { die "Unable to save in format bmp with your libgd" } }
            }
            when 'png' { gdImagePng($img,$imgh) }
            when 'gif' { gdImageGif($img, $imgh) }
            default { die "'$ext' not implemented" }
        }
        fclose($imgh);
    }

    method DESTROY {
        gdImageDestroy($!src-img) if $!src-img;
    }

    # Workaround until DESTROY works.
    method clean {
        gdImageDestroy($!src-img) if $!src-img;
    }
}

multi sub resize-image(Cool $src-img, Cool $dst-img, 
        $new-width, $new-height,
        :$no-resample, :$jpeg-quality) is export {

    Image::Resize.new($src-img).resize(
            $dst-img, $new-width, $new-height, :$no-resample, :$jpeg-quality).clean();
}

multi sub resize-image(Cool $src-img, Cool $dst-img, $factor,
        :$no-resample, :$jpeg-quality) is export {

    Image::Resize.new($src-img).resize(
            $dst-img, $factor, :$no-resample, :$jpeg-quality).clean();
}

=begin pod

=head1 NAME

Image::Resize - Resize images using GD

=head1 SYNOPSIS

    use Image::Resize;

    # Create a mini-me 1/10th your size
    resize-image("me.png", "mini-mi.jpg", 0.1);

    # Resize to exactly 400x400 pixels.
    resize-image("original.jpg", "resized.gif", 400, 400);
    
=head1 DESCRIPTION

C<Image::Resize> takes an image and resizes it. Can read jpg, png and gif
images and store the image in any format.

=head2 no-resample

Disable resample, which uses "smooth" copying from a large image to a smaller one,
using a weighted average of the pixels.

=head2 jpeg-quality

When copying to a jpeg image, you may specify this to change the quality
of the resized image. Range 0-95. A negative value will set it to default
jpeg value of GD.

=end pod
