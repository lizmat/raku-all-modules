use v6;
use Test;
use PDF::Content::Image;

throws-like { PDF::Content::Image.open( "t/images.t" ) }, ::('X::PDF::Image::UnknownType'), 'file extension check';

require ::('PDF::Content::Image::PNG');
throws-like { ::('PDF::Content::Image::PNG').read( "t/images/lightbulb.gif".IO.open ) }, ::('X::PDF::Image::WrongHeader'), 'PNG header-check';

require ::('PDF::Content::Image::JPEG');
throws-like { ::('PDF::Content::Image::JPEG').read( "t/images/lightbulb.gif".IO.open ) }, ::('X::PDF::Image::WrongHeader'), 'JPEG header-check';

require ::('PDF::Content::Image::GIF');
throws-like { ::('PDF::Content::Image::GIF').read( "t/images/basn0g01.png".IO.open ) }, ::('X::PDF::Image::WrongHeader'), 'GIF header-check';

done-testing;
