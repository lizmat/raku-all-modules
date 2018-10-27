use v6;
use Test;

use lib 'lib';
use Email::MIME::ParseContentType;

plan 16;

my $result = Email::MIME::ParseContentType.parse-content-type('');
is $result<type>, 'text', "Default content type parses <type>(text)...";
is $result<subtype>, 'plain', "...and <subtype>(plain)...";
is $result<attributes><charset>, 'us-ascii', "...and charset attribute.";

$result = Email::MIME::ParseContentType.parse-content-type('text/html; charset=utf-8');
is $result<type>, 'text', "Passed content type parses <type>(text)...";
is $result<subtype>, 'html', "...and <subtype>(plain)...";
is $result<attributes><charset>, 'utf-8', "...and charset attribute.";

$result = Email::MIME::ParseContentType.parse-content-type(
    "multipart/mixed; boundary=\"1154731954.d55bF4462.2751\"; charset=\"us-ascii\"");
is $result<type>, 'multipart', "Complex content type parses <type>...";
is $result<subtype>, 'mixed', "...and <subtype>...";
is $result<attributes><charset>, 'us-ascii', "...and charset attribute...";
is $result<attributes><boundary>, '1154731954.d55bF4462.2751', "...and boundary attribute.";

$result = Email::MIME::ParseContentType.parse-content-type(
    "multipart/mixed; boundary=\"1154731954.d55bF4462.2751\";\n charset=\"us-ascii\"");
is $result<type>, 'multipart', "Complex with newline content type parses <type>...";
is $result<subtype>, 'mixed', "...and <subtype>...";
is $result<attributes><charset>, 'us-ascii', "...and charset attribute...";
is $result<attributes><boundary>, '1154731954.d55bF4462.2751', "...and boundary attribute.";

$result = Email::MIME::ParseContentType.parse-content-type(
    "image/x-portable-greymap");
is $result<type>, "image", "content type with dashes <type>...";
is $result<subtype>, "x-portable-greymap", "...and <subtype>";
