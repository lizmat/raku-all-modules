use v6;
use Test;
use PDF::Content::Image;

throws-like { PDF::Content::Image.open( "t/images.t" ) }, X::PDF::Image::UnknownType, :message('unable to open as an image: t/images.t');

require ::('PDF::Content::Image::PNG');
throws-like { ::('PDF::Content::Image::PNG').read( "t/images/lightbulb.gif".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/lightbulb.gif image doesn't have a PNG header: \"GIF89a\\x\[13\]\\0\""), 'PNG header-check';

require ::('PDF::Content::Image::JPEG');
throws-like { ::('PDF::Content::Image::JPEG').read( "t/images/lightbulb.gif".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/lightbulb.gif image doesn't have a JPEG header: \"GI\""), 'JPEG header-check';

require ::('PDF::Content::Image::GIF');
throws-like { ::('PDF::Content::Image::GIF').read( "t/images/basn0g01.png".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/basn0g01.png image doesn't have a GIF header: \"\\x[89]PNG\\r\\n\""), 'GIF header-check';

done-testing;
