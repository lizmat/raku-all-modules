use NativeCall;

use soft; # for now
use Inline;

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

class GD::Image is repr('CPointer') {

	# This is pretty ugly so I'm looking for a more elegant solution...
	sub GD_add_point(OpaquePointer, int32 $idx, int32 $x, int32 $y) is inline('C') {'
		typedef struct {
			int x;
			int y;
		} gdPoint, *gdPointPtr;

		DLLEXPORT void GD_add_point(gdPointPtr points, int idx, int x, int y) {
			points[idx].x = x;
			points[idx].y = y;
		}
	'}

	sub GD_new_set_of_points(int32 $size)
		is inline('C') returns OpaquePointer {'
		#include <stdlib.h>

		typedef struct {
			int x;
			int y;
		} gdPoint, *gdPointPtr;

		DLLEXPORT gdPointPtr GD_new_set_of_points(int size) {
			gdPointPtr points;

			points = (gdPointPtr)malloc(size * sizeof(gdPoint));
			return points;
		}
	'}

	sub gdImageGif(GD::Image, GD::File)
		is native('libgd') { ... };

	sub gdImageJpeg(GD::Image, GD::File, int32)
		is native('libgd') { ... };

	sub gdImagePng(GD::Image, GD::File)
		is native('libgd') { ... };

	sub gdImageCreate(int32, int32)
		returns GD::Image is native('libgd') { ... };
	
	sub gdImageColorAllocate(GD::Image, int32, int32, int32)
		returns int32 is native('libgd') { ... };

	sub gdImageSetPixel(GD::Image, int32, int32, int32)
		is native('libgd') { ... };
		
	sub gdImageLine(GD::Image, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageFilledRectangle(GD::Image, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageRectangle(GD::Image, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageFilledArc(GD::Image, int32, int32, int32, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageArc(GD::Image, int32, int32, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageEllipse(GD::Image, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImageFilledEllipse(GD::Image, int32, int32, int32, int32, int32)
		is native('libgd') { ... };

	sub gdImagePolygon(GD::Image, OpaquePointer, int32, int32)
		is native('libgd') { ... };

	sub gdImageOpenPolygon(GD::Image, OpaquePointer, int32, int32)
		is native('libgd') { ... };

	sub gdImageFilledPolygon(GD::Image, OpaquePointer, int32, int32)
		is native('libgd') { ... };

	sub gdFree(OpaquePointer)
		is native('libgd') { ... };

	sub gdImageDestroy(GD::Image)
		is native('libgd') { ... };

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
		Parcel :$start(Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		Parcel :$end!(Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
		   Int :$color where { $color >= 0 } = 0) {

		gdImageLine(self, $x1, $y1, $x2, $y2, $color);
	}

	method rectangle(
		Parcel :$location(Int $x1 where { $x1 >= 0 }, Int $y1 where { $y1 >= 0 }) = (0, 0),
		Parcel :$size!(Int $x2 where { $x2 > 0 }, Int $y2 where { $y2 > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledRectangle(self, $x1, $y1, $x2, $y2, $color) !!
			gdImageRectangle(self, $x1, $y1, $x2, $y2, $color);
	}

	# style to enum
	method arc(
		Parcel :$center!(Int $cx, Int $cy),
		Parcel :$amplitude!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		Parcel :$aperture!(Int $s, Int $e),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False,
		   Int :$style = 0) {

		$fill ??
			gdImageFilledArc(self, $cx, $cy, $w, $h, $s, $e, $color, $style) !!
			gdImageArc(self, $cx, $cy, $w, $h, $s, $e, $color);
	}

	method ellipse(
		Parcel :$center!(Int $cx, Int $cy),
		Parcel :$axes!(Int $w where { $w > 0 }, Int $h where { $h > 0 }),
		   Int :$color where { $color >= 0 } = 0,
		  Bool :$fill = False) {

		$fill ??
			gdImageFilledEllipse(self, $cx, $cy, $w, $h, $color) !!
			gdImageArc(self, $cx, $cy, $w, $h, 0, 0, $color);
	}

	method circumference(
		Parcel :$center!(Int $cx, Int $cy),
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
