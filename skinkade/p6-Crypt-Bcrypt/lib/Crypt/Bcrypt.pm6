use v6;
use strict;
use NativeCall;
use Crypt::Random;

=begin LICENSE

Copyright (c) 2014-2015, carlin <cb@viennan.net>
Copyright (c) 2016, Shawn Kinkade

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

=end LICENSE

constant BCRYPT = %?RESOURCES<crypt_blowfish.so>.Str;



sub crypt(Str $key is encoded('utf8'), Str $setting is encoded('utf8'))
    is native(BCRYPT)
    returns Str 
    { * }

sub crypt_gensalt(Str $prefix is encoded('utf8'), uint32 $count, Buf $input, size_t $size)
    is native(BCRYPT)
    returns Str
    { * }

sub gensalt(int $rounds where 4..31) returns Str {
	crypt_gensalt('$2b$', $rounds, crypt_random_buf(16), 128);
}



sub bcrypt-hash(Str $password, int :$rounds = 12) returns Str is export {
	crypt($password, gensalt($rounds));
}

sub bcrypt-match(Str $password, Str $hash) returns Bool is export {
	crypt($password, $hash) eq $hash;
}

