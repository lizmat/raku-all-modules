use NativeCall;

use soft; # for now

enum GD_Format <GD_GIF GD_JPEG GD_PNG>;

class GD::File is repr('CPointer') {

	sub fopen(Str, Str)
		returns GD::File is native { ... }

	sub fclose(GD::File $filepointer)
		is native { ... }

	method new(Str $filename, Str $mode) {
		fopen($filename, $mode);
	}

	method close() {
		fclose(self);
	}
}

sub malloc(int32 $size) is native(Str) returns OpaquePointer {*};

class GD::Image is repr('CPointer') {

	# This is pretty ugly so I'm looking for a more elegant solution...
	sub GD_add_point(CArray[int32] $points, int32 $idx, int32 $x, int32 $y) {
	    $points[$idx * 2] = $x;
	    $points[$idx * 2 + 1] = $y;
	}

    sub GD_new_set_of_points(Int $size) returns OpaquePointer {
        malloc($size * 4 * 2);
    }

	sub gdImageGif(GD::Image, GD::File)
		is native('gd') { ... };

	sub gdImageJpeg(GD::Image, GD::File, int32)
		is native('gd') { ... };

	sub gdImagePng(GD::Image, GD::File)
		is native('gd') { ... };

	sub gdImageCreate(int32, int32)
		returns GD::Image is native('gd') { ... };
	
	sub gdImageColorAllocate(GD::Image, int32, int32, int32)
		returns int32 is native('gd') { ... };

	sub gdImageSetPixel(GD::Image, int32, int32, int32)
		is native('gd') { ... };
		
	sub gdImageLine(GD::Image, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageFilledRectangle(GD::Image, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageRectangle(GD::Image, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageFilledArc(GD::Image, int32, int32, int32, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageArc(GD::Image, int32, int32, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageEllipse(GD::Image, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImageFilledEllipse(GD::Image, int32, int32, int32, int32, int32)
		is native('gd') { ... };

	sub gdImagePolygon(GD::Image, OpaquePointer, int32, int32)
		is native('gd') { ... };

	sub gdImageOpenPolygon(GD::Image, OpaquePointer, int32, int32)
		is native('gd') { ... };

	sub gdImageFilledPolygon(GD::Image, OpaquePointer, int32, int32)
		is native('gd') { ... };

	sub gdFree(OpaquePointer)
		is native('gd') { ... };

	sub gdImageDestroy(GD::Image)
		is native('gd') { ... };

	### METHODS ###

	method new(Int $width, Int $height) {
		gdImageCreate($width, $height);
	}

	multi method colorAllocate(
			Int :$red! where 0..255,
			Int :$green! where 0..255,
			Int :$blue! where 0..255) returns Int {

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	multi method colorAllocate(Str $hexstr where /^ '#' <[A..Fa..f\d]>**6 $/) returns Int {

		my $red = ("0x" ~ $hexstr.substr(1,2)).Int;
		my $green = ("0x" ~ $hexstr.substr(3,2)).Int;
		my $blue = ("0x" ~ $hexstr.substr(5,2)).Int;

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	multi method colorAllocate(Int $hex_value where { $hex_value >= 0 }) returns Int {

		my $red = (($hex_value +> 16) +& 0xFF).Int;
		my $green = (($hex_value +> 8) +& 0xFF).Int;
		my $blue = (($hex_value) +& 0xFF).Int;

		return gdImageColorAllocate(self, $red, $green, $blue);
	}

	method pixel(
		Int $x where { $x >= 0 },
		Int $y where { $y >= 0 },
		Int $color where { $color >= 0 } = 0) {

		gdImageSetPixel(self, $x, $y, $color);
	}

	method line(
		List :$start (Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		List :$end! (Int $x2 where { $x2 >= 0 }, Int $y2 where { $y2 >= 0 }),
		   Int :$color where { $color >= 0 } = 0) {

		gdImageLine(self, $x1, $y1, $x2, $y2, $color);
	}

	method rectangle(
		List :$location (Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		List :$size! (Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color) !!
			gdImageRectangle(self, $x1, $y1, $x2, $y2, $color);
	}

	# style to enum
	method arc(
		List :$center!(Int $cx, Int $cy),
		List :$amplitude!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		List :$aperture!(Int $s, Int $e),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False,
		   Int :$style = 0) {

		$fill ??
			gdImageFilledArc(self, $cx, $cy, $w, $h, $s, $e, $color, $style) !!
			gdImageArc(self, $cx, $cy, $w, $h, $s, $e, $color);
	}

	method ellipse(
		List :$center!(Int $cx, Int $cy),
		List :$axes!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledEllipse(self, $cx, $cy, $w, $h, $color) !!
			gdImageArc(self, $cx, $cy, $w, $h, 0, 0, $color);
	}

	method circumference(
		List :$center!(Int $cx, Int $cy),
		   Int :$diameter! where { $diameter > 0 },
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledEllipse(self, $cx, $cy, $diameter, $diameter, $color) !!
			gdImageArc(self, $cx, $cy, $diameter, $diameter, 0, 0, $color);
	}

	method polygon(
		 Int :@points! where { @points.elems >= 6 && @points.elems % 2 == 0 },
		 Int :$color where { $color >= 0 } = 0,
		Bool :$fill = False,
		Bool :$open = False) returns OpaquePointer {

		my $n_array = @points.elems;
		my $gdPoints = GD_new_set_of_points(($n_array/2).Int);

		my $n = 0;
		for @points -> $x, $y {
			GD_add_point($gdPoints, $n, $x, $y);
			$n++;
		}

		$fill ??
			gdImageFilledPolygon(self, $gdPoints, $n, $color) !!
			$open ??
				gdImageOpenPolygon(self, $gdPoints, $n, $color) !!
				gdImagePolygon(self, $gdPoints, $n, $color);

		return $gdPoints;
	}

	method open(Str $filename, Str $mode) returns GD::File {
		return GD::File.new($filename, $mode);
	}

	method output(GD::File $filepointer, GD_Format $format, Int $quality = -1) {
		given $format {
			gdImageGif(self, $filepointer) when GD_GIF;
			gdImageJpeg(self, $filepointer, $quality) when GD_JPEG;
			gdImagePng(self, $filepointer) when GD_PNG;
		}
	}

	method free(OpaquePointer $storage) {
		gdFree($storage);
	}

	method destroy() {
		gdImageDestroy(self);
	}
}
