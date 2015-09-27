use v6;
use NativeCall;

=begin LICENSE

Copyright (c) 2014-2015, carlin <cb@viennan.net>

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

sub library returns Str {
	state Str $path;
	unless $path {
		constant $libname = 'crypt_blowfish.so';
		for @*INC {
			my $inc-path = $_.IO.path.subst(/ ['file#' || 'inst#'] /, '');
			my $check = $*SPEC.catfile($inc-path, $libname);
			if $check.IO ~~ :f {
				$path = $check;
				last;
			}
		}
		unless $path {
			die "Unable to locate library: $libname";
		}
	}
	$path;
}

my IO::Handle $urandom;

BEGIN {
	# open a handle to urandom in advance
	# so this will keep working in a chroot
	$urandom = open('/dev/urandom');
}

END {
	$urandom.close();
}

sub crypt(Str $key, Str $setting)
is native(&library) returns Str { ... }

sub crypt_gensalt(Str $prefix, int32 $count, Buf $input, int32 $size)
is native(&library) returns Str { ... }

sub crypt_ptr(Str $key, Pointer $setting)
is native(&library) is symbol('crypt') returns Str { ... }

sub crypt_gensalt_ptr(Str $prefix, int32 $count, Buf $input, int32 $size)
is native(&library) is symbol('crypt_gensalt') returns Pointer { ... }

class Crypt::Bcrypt {
	
	method gensalt(Int $rounds = 12) returns Str {
		# lower limit is log2(2**4 = 16) = 4
		# upper limit is log2(2**31 = 2147483648) = 31
		die "rounds must be between 4 and 31" unless $rounds ~~ 4..31;
		return crypt_gensalt('$2a$', $rounds, $urandom.read(16), 128);
	}

	method !gensalt_ptr(Int $rounds = 12) returns Pointer {
		die "rounds must be between 4 and 31" unless $rounds ~~ 4..31;
		return crypt_gensalt_ptr('$2a$', $rounds, $urandom.read(16), 128);
	}

	multi method hash(Str $password, Int $rounds = 12) returns Str {
		return crypt_ptr($password, self!gensalt_ptr($rounds));
	}

	multi method hash(Str $password, Str $salt) returns Str {
		return crypt($password, $salt);
	}

	method compare(Str $password, Str $hash) returns Bool {
		return Crypt::Bcrypt.hash($password, $hash) eq $hash;
	}
}

# vim: ft=perl6
