use GD::Raw;
use NativeCall;

sub gdAssertImageEqualsToFile($ex,$ac) is export {
    gdTestImageCompareToFile("caller",0, Str,$ex,$ac);
}

class CuTestImageResult {
	has $.pixels_changed is rw = 0;
	has $.max_diff is rw = 0;
};

sub gdTestImageFromPng(Cool $filename)
{
	my $fp = fopen($filename, "rb");

	return unless $fp;

    LEAVE { fclose($fp) if $fp; }
	return gdImageCreateFromPng($fp);
}


sub gdTestImageCompareToFile(Cool $file, Int $line,
    Str $message, Str $expected_file, gdImagePtr $actual)
{
    my $expected = gdTestImageFromPng($expected_file);

    unless $expected {
        warn "Cannot open PNG " ~ $expected_file;
        return 0;
    }

    LEAVE { gdImageDestroy($expected) if $expected }
    return gdTestImageCompareToImage($file, $line, $message, $expected, $actual);
}

# Return the largest difference between two corresponding pixels and
# channels.
sub gdMaxPixelDiff(gdImagePtr $a, gdImagePtr $b) is export
{
    my $diff = 0;
    my ($x, $y);

    die unless $a and $b;
    die unless $a.sx == $b.sx;
    die unless $a.sy == $b.sy;

    loop ($x = 0; $x < $a.sx; $x++) {
        loop ($y = 0; $y < $a.sy; $y++) {
			my $c1 = gdImageGetTrueColorPixel($a, $x, $y);
			my $c2 = gdImageGetTrueColorPixel($b, $x, $y);
            next if $c1 == $c2;

            $diff = max($diff, abs(gdTrueColorGetAlpha($c1) - gdTrueColorGetAlpha($c2)));
            $diff = max($diff, abs(gdTrueColorGetRed($c1)   - gdTrueColorGetRed($c2)));
            $diff = max($diff, abs(gdTrueColorGetGreen($c1) - gdTrueColorGetGreen($c2)));
            $diff = max($diff, abs(gdTrueColorGetBlue($c1)  - gdTrueColorGetBlue($c2)));
        }
    }

    return $diff;
}

# Compare two buffers, returning the number of pixels that are
# different and the maximum difference of any single color channel in
# result_ret.
#
# This function should be rewritten to compare all formats supported by
# cairo_format_t instead of taking a mask as a parameter.
#
sub gdTestImageDiff(gdImagePtr $buf_a, gdImagePtr $buf_b,
                     gdImagePtr $buf_diff, CuTestImageResult $result_ret is rw)
{
	my int ($x, $y);
	my int ($c1, $c2);

	loop ($y = 0; $y < gdImageSY($buf_a); $y++) {
		loop ($x = 0; $x < gdImageSX($buf_a); $x++) {
			$c1 = gdImageGetTrueColorPixel($buf_a, $x, $y);
			$c2 = gdImageGetTrueColorPixel($buf_b, $x, $y);

            # check if the pixels are the same
			if ($c1 != $c2) {
				my int ($r1,$b1,$g1,$a1,$r2,$b2,$g2,$a2);
				my ($diff_a,$diff_r,$diff_g,$diff_b);

				$a1 = gdTrueColorGetAlpha($c1);
				$a2 = gdTrueColorGetAlpha($c2);
				$diff_a = ($a1 - $a2).abs;
				$diff_a *= 4; # emphasize

				if ($diff_a) {
					$diff_a += 128; # make sure it's visible
				}

                if ($diff_a > gdAlphaMax) {
					$diff_a = gdAlphaMax/2;
				}

				$r1 = gdTrueColorGetRed($c1);
				$r2 = gdTrueColorGetRed($c2);
				$diff_r = ($r1 - $r2).abs;
                $diff_r *= 4; # TODO: This line commented out or not?
				if ($diff_r) {
					$diff_r += gdRedMax/2; # make sure it's visible
				}
				if ($diff_r > 255) {
					$diff_r = 255;
				}

				$g1 = gdTrueColorGetGreen($c1);
				$g2 = gdTrueColorGetGreen($c2);
				$diff_g = ($g1 - $g2).abs;

				$diff_g *= 4;  # emphasize
				if ($diff_g) {
					$diff_g += gdGreenMax/2; # make sure it's visible
				}
				if ($diff_g > 255) {
					$diff_g = 255;
				}

				$b1 = gdTrueColorGetBlue($c1);
				$b2 = gdTrueColorGetBlue($c2);
				$diff_b = ($b1 - $b2).abs;
				$diff_b *= 4;  # emphasize
				if ($diff_b) {
					$diff_b += gdBlueMax/2; # make sure it's visible
				}
				if ($diff_b > 255) {
					$diff_b = 255;
				}

				$result_ret.pixels_changed++;
				if ($buf_diff) {
                    gdImageSetPixel($buf_diff, $x,$y, gdTrueColorAlpha($diff_r, $diff_g, $diff_b, $diff_a));
                }
			} else {
				if ($buf_diff) {
                    gdImageSetPixel($buf_diff, $x,$y, gdTrueColorAlpha(255,255,255,0));
                }
			}
		}
	}
}

sub tmp-file() {
    my $path = $*TMPDIR;
    $path = $path.child( ('a'..'z', 'A'..'Z').pick(10).join ~ ".png" );
    return $path.Str;
}

sub gdTestImageCompareToImage($file, $line, $message,
                              $expected, $actual)
{
	my Int ($width_a, $height_a);
	my Int ($width_b, $height_b);
	my gdImagePtr $surface_diff;
	my $result = CuTestImageResult.new;

	if (!$actual) {
        warn "actual missing";
        return 0;
	}

	$width_a  = gdImageSX($expected);
	$height_a = gdImageSY($expected);
	$width_b  = gdImageSX($actual);
	$height_b = gdImageSY($actual);

	if ($width_a  != $width_b  || $height_a != $height_b) {
        warn "Image size mismatch: ($width_a x $height_a) vs. "
            ~ "($width_b x $height_b)\n\t for $file vs. buffer\n";
	    return 0;
	}

	$surface_diff = gdImageCreateTrueColor($width_a, $height_a);
    LEAVE { gdImageDestroy($surface_diff) if $surface_diff; }

	gdTestImageDiff($expected, $actual, $surface_diff, $result);
	if ($result.pixels_changed > 0) {
		my Str $file_diff;
		my Str $file_out;
		my OpaquePointer $fp;
		my int ($len, $p);

        warn "Total pixels changed: " ~ $result.pixels_changed
            ~ " with a maximum channel difference of " ~ $result.max_diff;

        my $actual-path = tmp-file();
        my $diff-path = tmp-file();

        my $afh = fopen($actual-path, "wb");
        return 0 unless $afh;
        my $dfh = fopen($diff-path, "wb");
        return 0 unless $dfh;

        say "Writing actual to $actual-path, expected to $diff-path";
        gdImagePng($actual, $afh);
        gdImagePng($expected, $dfh);

        LEAVE {
            fclose($afh) if $afh;
            fclose($dfh) if $dfh;
        }

        return 0;
	}

	return 1;
}


# set ft=perl6
