use Base64::Native;

use Test;

is base64-encode("").decode, "", "encode 0 bytes";
is base64-encode("a").decode, "YQ==", "encode 1 byte";
is base64-encode("ab").decode, "YWI=", "encode 2 bytes";
is base64-encode("abc").decode, "YWJj", "encode 3 bytes";
is base64-encode("abcd").decode, "YWJjZA==", "encode 4 bytes";

my $text = q:to<-END->.lines.join: ' ';
Man is distinguished, not only by his reason, but by this singular passion from
other animals, which is a lust of the mind, that by a perseverance of delight
in the continued and indefatigable generation of knowledge, exceeds the short
vehemence of any carnal pleasure.
-END-

my $base64 = q:to<-END->.lines.join;
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
-END-

is base64-encode($text).decode, $base64, "longer encoding";

my $trunc-out = buf8.allocate(10);
is base64-encode($text, $trunc-out).decode, $base64.substr(0,10), "truncated encoding";

is base64-decode("YWJj").decode, "abc", "decode to 3 bytes";
is base64-decode("YWI=").decode, "ab", "decode to 2 bytes";
is base64-decode("YQ==").decode, "a", "decode to 1 bytes";
is base64-decode("").decode, "", "decode to 1 bytes";
is base64-decode("YWJjZA==").decode, "abcd", "decode to 4 bytes";
is base64-decode("YWJjZA").decode, "abcd", "decode no padding";
is base64-decode(" Y\nWJj ZA == ").decode, "abcd", "decode whitespace";
is-deeply base64-decode("-_== "), base64-decode("+/== "), "URI encoding";
dies-ok {base64-decode("YW(=").decode}, "decode invalid input";

is base64-decode($base64).decode, $text, "longer decoding";
is base64-decode($base64, $trunc-out).decode, $text.substr(0,10), "truncated decoding";

my $all-std = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
my $all-uri = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
is base64-encode(base64-decode($all-std)).decode, $all-std, "charset roundtrip";
is base64-encode(base64-decode($all-uri)).decode, $all-std, "charset roundtrip";
is base64-encode(base64-decode($all-uri), :uri).decode, $all-uri, "charset roundtrip (uri)";

done-testing;
