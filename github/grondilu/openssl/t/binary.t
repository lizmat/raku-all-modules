use SSL::Digest;
use Test;

plan 10;

my $test-buffer = Buf.new: (^256).roll: 100.pick;

sub openssl($dgst, $buf = $test-buffer) {
    my $buffer-as-string = [~] map { sprintf("%02x", $_) }, $buf.list;
    qqx{
	perl -e 'print pack "H*", "$buffer-as-string"' |
	openssl dgst -$dgst -binary|
	perl -e 'print unpack "H*", join "", <>;'
    }
}

is md4($test-buffer).unpack('H*'), openssl('md4'), 'MD4';
is md5($test-buffer).unpack('H*'), openssl('md5'), 'MD5';
is sha0($test-buffer).unpack('H*'), openssl('sha'), 'SHA-0';
is sha1($test-buffer).unpack('H*'), openssl('sha1'), 'SHA-1';
is sha224($test-buffer).unpack('H*'), openssl('sha224'), 'SHA-224';
is sha256($test-buffer).unpack('H*'), openssl('sha256'), 'SHA-256';
is sha384($test-buffer).unpack('H*'), openssl('sha384'), 'SHA-384';
is sha512($test-buffer).unpack('H*'), openssl('sha512'), 'SHA-512';
is rmd160($test-buffer).unpack('H*'), openssl('rmd160'), 'RIPEMD-160';
is whirlpool($test-buffer).unpack('H*'), openssl('whirlpool'), 'WHIRLPOOL';

# vim: ft=perl6
