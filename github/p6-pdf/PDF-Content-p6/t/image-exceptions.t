use v6;
use Test;
use PDF::Content::XObject;

throws-like { PDF::Content::XObject.open( "t/images.t" ) }, X::PDF::Image::UnknownType, :message('Unable to open as an image: t/images.t');

throws-like { PDF::Content::XObject.open( "data:text/plain;base64,SGVsbG8sIFdvcmxkIQ%3D%3D" ) }, X::PDF::Image::UnknownMimeType, :message("Expected mime-type 'image/*' or 'application/pdf', got 'text': data:text/plain;base64,");

throws-like { (require ::('PDF::Content::Image::PNG')).read( "t/images/lightbulb.gif".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/lightbulb.gif image doesn't have a PNG header: \"GIF89a\\x\[13\]\\0\""), 'PNG header-check';

throws-like { (require ::('PDF::Content::Image::JPEG')).read( "t/images/lightbulb.gif".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/lightbulb.gif image doesn't have a JPEG header: \"GI\""), 'JPEG header-check';

throws-like { (require ::('PDF::Content::Image::GIF')).read( "t/images/basn0g01.png".IO.open ) }, X::PDF::Image::WrongHeader, :message("t/images/basn0g01.png image doesn't have a GIF header: \"\\x[89]PNG\\r\\n\""), 'GIF header-check';

done-testing;
