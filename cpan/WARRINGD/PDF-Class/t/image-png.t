use v6;
use Test;
use PDF::Class::Type;
use PDF::XObject::Image;
use PDF::Content::Image::PNG;

sub check-png($png) {
    is $png.hdr.width, 32, 'width';
    is $png.hdr.height, 32, 'height';
    is $png.hdr.bit-depth, 8, 'bit-depth';
    is $png.hdr.color-type, 0, 'color-type';
    is $png.hdr.compression-type, 0, 'compression-type';
    is $png.hdr.interlace-type, 0, 'interlace-type';
    is-deeply $png.Buf, Buf[uint8].new(137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,32,0,0,0,32,8,0,0,0,0,86,17,37,40,0,0,0,65,73,68,65,84,120,156,99,100,96,36,0,20,8,200,179,12,5,5,140,15,8,41,248,247,31,63,96,121,48,28,20,48,202,17,144,103,100,162,121,92,12,6,5,140,143,240,202,254,255,207,248,135,230,113,49,24,20,48,202,224,149,101,100,4,0,80,229,254,113,53,226,216,89,0,0,0,0,73,69,78,68,174,66,96,130), '.Buf';

}

my $png1 = PDF::Content::Image::PNG.new.read: "t/images/basn0g08.png".IO.open(:r);

check-png($png1);

my $dict = $png1.to-dict;
isa-ok $dict, PDF::XObject::Image;
is $dict<Width>, 32, 'dict width';
is $dict<Height>, 32, 'dict height';
is $dict<BitsPerComponent>, 8, 'dict bpc';
is $dict<ColorSpace>, 'DeviceGray', 'dict color-space';
is $dict<Filter>, 'FlateDecode', 'dict filter';

my $png2 = $dict.to-png;

check-png($png2);

done-testing;
