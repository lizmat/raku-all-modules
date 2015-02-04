use SSL::Digest;
use Test;

plan 11;

my Buf $random-bytes = Buf.new: (^128).roll: 10.pick;
sub openssl($dgst, Buf $bytes = $random-bytes) {
    my $hex = [~] map { sprintf "%02x", $_ }, $bytes.list;

    qqx{
	perl -e 'print pack q/H*/, q/$hex/' |
	openssl dgst -$dgst -binary |
	perl -e 'print unpack "H*", join "", <>;'
    }
}

my $str = [~] map &chr, $random-bytes.list;
is md4($str).unpack('H*'), openssl('md4'), 'MD4';
is md5($str).unpack('H*'), openssl('md5'), 'MD5';
is sha0($str).unpack('H*'), openssl('sha'), 'SHA-0';
is sha1($str).unpack('H*'), openssl('sha1'), 'SHA-1';
is sha224($str).unpack('H*'), openssl('sha224'), 'SHA-224';
is sha256($str).unpack('H*'), openssl('sha256'), 'SHA-256';
is sha384($str).unpack('H*'), openssl('sha384'), 'SHA-384';
is sha512($str).unpack('H*'), openssl('sha512'), 'SHA-512';
is rmd160($str).unpack('H*'), openssl('rmd160'), 'RIPEMD-160';
is whirlpool($str).unpack('H*'), openssl('whirlpool'), 'WHIRLPOOL';

# md2 no longer seems to be exposed via the openssl command line
# and 'openssl md2' silently (!) gives the same result as md5
#is md2('').unpack('H*'), '8350e5a3e24c153df2275c9f80692773', 'MD2 (empty string)';
#is md2('The quick brown fox jumps over the lazy dog').unpack('H*'), '03d85a0d629d2c442e987525319fc471', 'MD2 (quick brown fox)';

$str = "æ€!éè";
is
sha256($str).unpack('H*'),
qqx{ perl -e 'use Digest::SHA qw(sha256_hex); print sha256_hex "$str"' },
'SHA-256 with a unicode string';

# vim: ft=perl6
