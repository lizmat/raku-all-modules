use v6;

use Test;
use HTTP::Request::FormData;

sub condec($v) {
    $v.chomp.subst("\n", "\r\n", :g)
}
sub conenc($v) { condec($v).encode }

my $fd = HTTP::Request::FormData.new;

isa-ok $fd, HTTP::Request::FormData;

is $fd.parts.elems, 0;

$fd.add-part('one', 'two');

is $fd.parts.elems, 1;
is $fd.parts[0].name, 'one';
is $fd.parts[0].value, 'two';
is $fd.parts[0].content.decode, condec(q:to/END_OF_ONE/);
Content-Disposition: form-data; name="one"

two
END_OF_ONE

$fd.add-part('three', 'four', :content-type<text/plain>);
is $fd.parts.elems, 2;
is $fd.parts[0].name, 'one';
is $fd.parts[1].name, 'three';
is $fd.parts[1].value, 'four';
is $fd.parts[1].content-type, 'text/plain';
is $fd.parts[1].content.decode, condec(q:to/END_OF_THREE/);
Content-Disposition: form-data; name="three"
Content-Type: text/plain

four
END_OF_THREE

$fd.add-part('five', 'six', :content-type<text/fancy>, :filename<seven.txt>);
is $fd.parts.elems, 3;
is $fd.parts[0].name, 'one';
is $fd.parts[1].name, 'three';
is $fd.parts[2].name, 'five';
is $fd.parts[2].value, 'six';
is $fd.parts[2].content-type, 'text/fancy';
is $fd.parts[2].filename, 'seven.txt';
is $fd.parts[2].content.decode, condec(q:to/END_OF_FIVE/);
Content-Disposition: form-data; name="five"; filename="seven.txt"
Content-Type: text/fancy

six
END_OF_FIVE

$fd.add-part('eight', 't/nine.txt'.IO, :content-type<application/octet-stream>);

is $fd.parts.elems, 4;
is $fd.parts[0].name, 'one';
is $fd.parts[1].name, 'three';
is $fd.parts[2].name, 'five';
is $fd.parts[3].name, 'eight';
is $fd.parts[3].value, 't/nine.txt';
is $fd.parts[3].content.decode, condec(q:to/END_OF_EIGHT/);
Content-Disposition: form-data; name="eight"; filename="nine.txt"
Content-Type: application/octet-stream

Hello World! Ten

END_OF_EIGHT

cmp-ok $fd.boundary.chars, '>=', 5;

is $fd.content-type, "multipart/form-data; boundary=$fd.boundary()";

is $fd.content.decode, condec(qq:to/END_OF_CONTENT/);
--$fd.boundary()
Content-Disposition: form-data; name="one"

two
--$fd.boundary()
Content-Disposition: form-data; name="three"
Content-Type: text/plain

four
--$fd.boundary()
Content-Disposition: form-data; name="five"; filename="seven.txt"
Content-Type: text/fancy

six
--$fd.boundary()
Content-Disposition: form-data; name="eight"; filename="nine.txt"
Content-Type: application/octet-stream

Hello World! Ten

--{$fd.boundary()}--

END_OF_CONTENT

done-testing;
