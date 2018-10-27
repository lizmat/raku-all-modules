use v6;

# from http://tools.ietf.org/html/rfc4648#section-10

use Test;

use lib 'lib';

use MIME::Base64;

my MIME::Base64 $mime .= new;

plan 16;

is $mime.encode-str(''), '', 'Encoding the empty string';
is $mime.encode-str('f'), 'Zg==', 'Encoding "f"';
is $mime.encode-str('fo'), 'Zm8=', 'Encoding "fo"';
is $mime.encode-str('foo'), 'Zm9v', 'Encoding "foo"';
is $mime.encode-str('foob'), 'Zm9vYg==', 'Encoding "foob"';
is $mime.encode-str('fooba'), 'Zm9vYmE=', 'Encoding "fooba"';
is $mime.encode-str('foobar'), 'Zm9vYmFy', 'Encoding "foobar"';

is $mime.decode-str(''), '', 'Decoding the empty string';
is $mime.decode-str('Zg=='), 'f', 'Decoding "f"';
is $mime.decode-str('Zm8='), 'fo', 'Decoding "fo"';
is $mime.decode-str('Zm9v'), 'foo', 'Decoding "foo"';
is $mime.decode-str('Zm9vYg=='), 'foob', 'Decoding "foob"';
is $mime.decode-str('Zm9vYmE='), 'fooba', 'Decoding "fooba"';
is $mime.decode-str('Zm9vYmFy'), 'foobar', 'Decoding "foobar"';

# not from RFC test vector but one odd test case from w3 HTTP spec and
# perl 5 test suite
is $mime.encode-str('Aladdin:open sesame'),
    'QWxhZGRpbjpvcGVuIHNlc2FtZQ==', 'Encoding w3 http spec test open sesame';
is $mime.decode-str('QWxhZGRpbjpvcGVuIHNlc2FtZQ=='), 'Aladdin:open sesame',
    'Decoding w3 http spec test open sesame';


