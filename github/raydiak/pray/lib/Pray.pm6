unit module Pray;

use Pray::Scene;
use Pray::Output;

our sub render (
    $scene_file,
    $out_file,
    Int $width is copy,
    Int $height is copy,
    Bool :$quiet = True,
    Bool :$verbose = False,
    Bool :$preview = !$quiet
) {
    if !$height {
        if $width {
            $height = $width;
        } else {
            die 'Width and/or height must be specified';
        }
    } elsif !$width {
        $width = $height;
    }
    
    my $scene = Pray::Scene.load($scene_file);
    my $out = Pray::Output.new:
        :file($out_file),
        :$width, :$height,
        :$preview,
        :$quiet;

    for ^$height -> $y {
        for ^$width -> $x {
            my $color = $scene.camera.screen_coord_color(
                $x, $y,
                $width, $height,
                $scene
            ).clip;

            $out.set: $x, $y, $color.r, $color.g, $color.b;
        }
    }

    $out.write;
}

