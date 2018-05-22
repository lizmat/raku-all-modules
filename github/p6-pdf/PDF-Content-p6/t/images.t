use v6;
use Test;
plan 180;
use PDF::Grammar::Test :is-json-equiv;
use lib '.';
use PDF::Content::XObject;
use t::PDFTiny;
# ensure consistant document ID generation
srand(123456);

my Pair @images;

my $jpeg;
lives-ok {$jpeg = PDF::Content::XObject.open: "t/images/jpeg.jpg";}, "open jpeg - lives";
@images.push: 'JPEG - Content' => $jpeg;
isa-ok $jpeg, ::('PDF::COS::Stream'), 'jpeg object';
is $jpeg<Type>, 'XObject', 'jpeg type';
is $jpeg<Subtype>, 'Image', 'jpeg subtype';
is $jpeg<Width>, 24, 'jpeg width';
is $jpeg<Height>, 24, 'jpeg height';
is $jpeg<BitsPerComponent>, 8, 'jpeg bpc';
is $jpeg<ColorSpace>, 'DeviceRGB', 'jpeg cs';
ok $jpeg<Length>, 'jpeg dict length';
is $jpeg.encoded.codes, $jpeg<Length>, 'jpeg encoded length';
is $jpeg.width, 24, 'jpeg width';
is $jpeg.height, 24, 'jpeg height';

my $gif;
lives-ok {$gif = PDF::Content::XObject.open: "t/images/lightbulb.gif";}, "open gif - lives";
@images.push: 'GIF - Content' => $gif;
isa-ok $gif, ::('PDF::COS::Stream'), 'gif object';
is $gif<Type>, 'XObject', 'gif type';
is $gif<Subtype>, 'Image', 'gif subtype';
is $gif<Width>, 19, 'gif width';
is $gif<Height>, 19, 'gif height';
is $gif<BitsPerComponent>, 8, 'gif bpc';
is-json-equiv $gif<ColorSpace>, ['Indexed', 'DeviceRGB', 31, "\xFF\xFF\xFF\xFF\xFB\xF0\xFF\xDF\xFF\xD4\xDF\xFF\xCC\xCC\xFF\xC0\xDC\xC0\xA6\xCA\xF0\xFF\x98\xFF\xFF\xFF\xAA\xFF\xDF\xAA\xD4\xDF\xAA\xD4\xBF\xAA\xD4\x9F\xAA\xAA\xBF\xAA\xA0\xA0\xA4\xAA\x9F\xAA\x80\x80\x80\x7F\x9F\xAA\xFF\xFF\x55\xFF\xDF\x55\xD4\xBF\x55\xD4\x9F\x55\xAA\x9F\x55\x80\x80\x00\xAA\x7F\x55\xAA\x5F\x55\xAA\x7F\x00\x7F\x5F\x55\x55\x5F\x55\x2A\x5F\x55\x55\x3F\x55\x00\x00\x00" ], 'gif cs';
ok $gif<Length>, 'gif dict length';
is $gif.encoded.codes, $gif<Length>, 'gif encoded length';

is $gif.data-uri, 'data:image/gif;base64,R0lGODlhEwATAMQAAP/////78P/f/9Tf/8zM/8DcwKbK8P+Y////qv/fqtTfqtS/qtSfqqq/qqCgpKqfqoCAgH+fqv//Vf/fVdS/VdSfVaqfVYCAAKp/VapfVap/AH9fVVVfVSpfVVU/VQAAACH5BAkIAAcALAAAAAATABMAAAWsoFYcJLmcY0lqx5Kl7UJR1aNiy1gMR7EkAYSQwoDtSr5AcCJJICgYgar0QySaQuGJN10gmMKgUFGBYViWqxOhVJJt58LogWW3A4vagWuqICR2AAB4GA1TJBgTVm0AChsPMCoFGBRZARYbDpFTBRB+CBiPBVJTLH1CmSkXCyU4owcPHBAQHA9cCxgwBCkODgYOHoZImyQOEQa0wodTDrMdHjbLh7McmtLLcsQkIQA7', 'data-uri from file';

my $image1;
if lives-ok({$image1 = t::PDFTiny.open("t/images/tiny.pdf").page(1).to-xobject;}, "open PDF as image - lives") {
    is $image1.width, 48, 'PDF image width';
    is $image1.height, 60, 'PDF image height';
    @images.push: 'PDF - Form' => $image1;
}

my $image2;
my $image-data = "data:image/gif;base64,R0lGODlhEAAOALMAAOazToeHh0tLS/7LZv/0jvb29t/f3//Ub//ge8WSLf/rhf/3kdbW1mxsbP//mf///yH5BAAAAAAALAAAAAAQAA4AAARe8L1Ekyky67QZ1hLnjM5UUde0ECwLJoExKcppV0aCcGCmTIHEIUEqjgaORCMxIC6e0CcguWw6aFjsVMkkIr7g77ZKPJjPZqIyd7sJAgVGoEGv2xsBxqNgYPj/gAwXEQA7";
$image2 = PDF::Content::XObject.open: $image-data;
if lives-ok({$image2 = PDF::Content::XObject.open: $image-data;}, "open GIF data url - lives") {
    @images.push: 'Data URI (GIF)' => $image2;
}
is $image2.data-uri, $image-data, 'data-uri from source string';

# example from https://en.wikipedia.org/wiki/Data_URI_scheme
$image-data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAD///+l2Z/dAAAAM0lEQVR4nGP4/5/h/1+G/58ZDrAz3D/McH8yw83NDDeNGe4Ug9C9zwz3gVLMDA/A6P9/AFGGFyjOXZtQAAAAAElFTkSuQmCC";
my $image3;
if lives-ok({$image3 = PDF::Content::XObject.open: $image-data;}, "open PNG data url - lives") {
    @images.push: 'Data URI (PNG)' => $image3;
}
is $image3.data-uri, $image-data, 'data-uri from source string';

my $png-data-uri = '?';
lives-ok {
    $png-data-uri = PDF::Content::XObject.open("t/images/basn0g01.png").data-uri;
    PDF::Content::XObject.open($png-data-uri);
}, 'round-trip open of PNG uri'
    or note "round-trip uri: {$png-data-uri.substr(0,32)}...";

for (
    'png-1bit-gray' => {
        :file<t/images/basn0g01.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceGray>, :BitsPerComponent(1),
        :Colors(1), :Columns(32), :Predictor(15), },
    'png-4bit-gray' => {
        :file<t/images/basn0g04.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceGray>, :BitsPerComponent(4),
        :Colors(1), :Columns(32), :Predictor(15), },
    'png-8bit-gray' => {
        :file<t/images/basn0g08.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceGray>, :BitsPerComponent(8),
        :Colors(1), :Columns(32), :Predictor(15), },
    'png-16bit-gray' => {
        :file<t/images/basn0g16.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceGray>, :BitsPerComponent(16),
        :Colors(1), :Columns(32), :Predictor(15), },
    'png-8bit-rgb' => {
        :file<t/images/basn2c08.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceRGB>, :BitsPerComponent(8),
        :Colors(3), :Columns(32), :Predictor(15), },
    'png-16bit-rgb' => {
        :file<t/images/basn2c16.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceRGB>, :BitsPerComponent(16),
        :Colors(3), :Columns(32), :Predictor(15), },
    'png-8bit-rgb+alpha' => {
        :file<t/images/g03n2c08.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>, :ColorSpace<DeviceRGB>, :BitsPerComponent(8),
        :Colors(3), :Columns(32), :Predictor(15), },
    'png-2bit-palette' => {
        :file<t/images/basn3p02.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>,
	:ColorSpace[ 'Indexed', 'DeviceRGB', 3, { :Length(12) } ],
	:BitsPerComponent(2),
        :Colors(1), :Columns(32), :Predictor(15), },
    'png-8bit-gray+alpha' => {
        :file<t/images/basn4a08.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>,
	:ColorSpace<DeviceGray>,
	:BitsPerComponent(8),
	:SMask{
	    :Type<XObject>, :Subtype<Image>,
	    :BitsPerComponent(8), :ColorSpace<DeviceGray>, :Filter<FlateDecode>,
	    :Width(32), :Height(32),
	},
	:Colors(1), :Columns(32), :Predictor(15) },
    'png-16bit-gray+alpha' => {
        :file<t/images/basn4a16.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>,
	:ColorSpace<DeviceGray>,
	:BitsPerComponent(16),
	:SMask{
	    :Type<XObject>, :Subtype<Image>,
	    :BitsPerComponent(16), :ColorSpace<DeviceGray>, :Filter<FlateDecode>,
	    :Width(32), :Height(32),
	},
	:Colors(1), :Columns(32), :Predictor(15) },
    'png-8bit-rgb+alpha' => {
        :file<t/images/basn6a08.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>,
	:ColorSpace<DeviceRGB>,
	:BitsPerComponent(8),
	:SMask{
	    :Type<XObject>, :Subtype<Image>,
	    :BitsPerComponent(8), :ColorSpace<DeviceGray>, :Filter<FlateDecode>,
	    :Width(32), :Height(32),
	},
	:Colors(3), :Columns(32), :Predictor(15) },
    'png-16bit-rgb+alpha' => {
        :file<t/images/basn6a16.png>, :Width(32), :Height(32),
        :Filter<FlateDecode>,
	:ColorSpace<DeviceRGB>,
	:BitsPerComponent(16),
	:SMask{
	    :Type<XObject>, :Subtype<Image>,
	    :BitsPerComponent(16), :ColorSpace<DeviceGray>, :Filter<FlateDecode>,
	    :Width(32), :Height(32),
	},
	:Colors(3), :Columns(32), :Predictor(15) },
    )  {
    my $desc = .key;
    my $test = .value;

    my $png;
    lives-ok { $png = PDF::Content::XObject.open: $test<file>; }, "open $desc - lives";
    isa-ok $png, ::('PDF::COS::Stream'), "$desc object";
    @images.push: $desc => $png;
    
    is $png<Type>, 'XObject', "$desc type";
    is $png<Subtype>, 'Image', "$desc subtype";
    is $png<Width>, $test<Width>, "$desc width";
    is $png<Height>,$test<Height>, "$desc height";
    is $png<Filter>, $test<Filter>, "$desc filter";
    is $png<ColorSpace>, $test<ColorSpace>, "$desc color-space";
    is $png<SMask>, $test<SMask>, "$desc SMask"
	if $test<SMask>:exists;

    my $decode = $png<DecodeParms>;
    is $decode<BitsPerComponent>, $test<BitsPerComponent>, "$desc decode bpc";
    is $decode<Colors>, $test<Colors>, "$desc decode colors";
    is $decode<Columns>,$test<Columns>, "$desc decode columns";
    is $decode<Predictor>, $test<Predictor>, "$desc decode predictor";
}

sub save-images(@images) {
    my $doc = t::PDFTiny.new;
    my $page = $doc.add-page;
    $page.MediaBox = [0,0,612,792];
    my $x = 45;
    my $y = 650;
    my $n = 0;

    $page.graphics: {
        .FillColor = :DeviceRGB[ .9, .9, .95 ];
        .Rectangle: |$page.MediaBox;
        .Fill;
    }

    $page.graphics: -> $gfx {
	$gfx.font = $page.core-font( :family<Times-Roman>, :weight<bold>);
	$gfx.print( "PDF::Content [t/images.t] - assorted images",
                    :position[30, 750] );

	$gfx.font = ($page.core-font( :family<Times-Roman>), 12);
    
	for @images {
	    my ($desc, $img) = .kv;
	    $gfx.do($img, $x, $y,);
	    $gfx.print($desc, :position[$x + 45, $y + 15]);
	    if ++$n %% 3 {
		$x = 45;
		$y -= 75;
	    }
	    else {
		$x += 200;
	    }
	}
    }
    
    $doc.save-as: "t/images.pdf";
}

lives-ok { save-images(@images) }, 'save-images - lives';

done-testing;
