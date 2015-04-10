use v6;

use Test;

use lib 'lib';

use MIME::Base64;

plan 11;

# The tests are a bit hacky at this point but recommended as needed
# because the point of base64 in MIME/email is to encode binary data.

my MIME::Base64 $mime .= new;

is $mime.encode(Blob.new(0)), 'AA==', 'encode test on NULL/0 byte';
is $mime.encode(Blob.new(1, 0)), 'AQA=', 'test NULL byte in second slot';
is $mime.encode(Blob.new(1)), 'AQ==', 'encode test on byte value 1';
is $mime.encode(Blob.new(255)), '/w==', 'encode test on byte value 255';
ok $mime.decode('AA==') eq Blob.new(0), 'decode test on NULL/0 byte';
ok $mime.decode('AQ==') eq Blob.new(1), 'decode test on byte value 1';
ok $mime.decode('/w==') eq Blob.new(255), 'decode test on byte value 255';

my $fancy-unicode-chars = "\c[ LEFT CORNER BRACKET ]\c[ SNOWMAN ]\c[
NEITHER LESS-THAN NOR EQUIVALENT TO ]\c[ GREEK CAPITAL LETTER SIGMA ]";

my  Str $long-enc = "DDADJnQiowMMMAMmdCKjAwwwAyZ0IqMDDDADJnQi"
                        ~ "owMMMAMmdCKjAwwwAyZ0IqMDDDADJnQiowM=\n";

my blob16 $fancy-utf16-chars = $fancy-unicode-chars.encode('UTF-16');
# pack 'S*' doesn't work yet so work around by repeating
my blob8 $fancy-utf16-chars-bytes =
    pack 'S' x $fancy-utf16-chars.elems, $fancy-utf16-chars.list;
is $mime.encode($fancy-utf16-chars-bytes), 'DDADJnQiowM=',
    'encode some binary utf16 data';
is $mime.decode('DDADJnQiowM=').decode('UTF-16'), $fancy-unicode-chars,
    'decode some binary utf16 data';

$fancy-unicode-chars x= 7;
$fancy-utf16-chars = $fancy-unicode-chars.encode('UTF-16');
# pack 'S*' doesn't work yet so work around by repeating
$fancy-utf16-chars-bytes =
    pack 'S' x $fancy-utf16-chars.elems, $fancy-utf16-chars.list;
is $mime.encode($fancy-utf16-chars-bytes), $long-enc,
    'encode enough binary utf16 data for more than one line of result';
is $mime.decode($long-enc).decode('UTF-16'), $fancy-unicode-chars,
    'decode more than one line encoding of binary utf16 data';

