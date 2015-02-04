use v6;
use NativeCall;
use LibraryMake;

=begin LICENSE

This Source Code Form is subject to the terms of the ISC License.
If a copy of the license was not distributed with this
file, you can obtain one at http://opensource.org/licenses/isc-license.txt

=end LICENSE

sub library returns Str {
	my $so = get-vars('')<SO>;
	for @*INC {
		if ($_~'/crypt_blowfish'~$so).IO ~~ :f {
			return $_~'/crypt_blowfish'~$so;
		}
	}
	die 'unable to find library crypt_blowfish';
}

sub crypt(Str $key, Str $setting)
	returns Str
	# is native('crypt_blowfish.so')
	{*}
trait_mod:<is>(&crypt, :native(library));

sub crypt_gensalt(Str $prefix, int32 $count, Str $input, int32 $size)
	returns Str
	# is native('crypt_blowfish.so')
	{*}
trait_mod:<is>(&crypt_gensalt, :native(library));

class Crypt::Bcrypt {
	
	sub rand_chars(Int $chars = 16) returns Str {
		my $fh = open('/dev/urandom');
		my $bin = $fh.read($chars);
		$fh.close();
		return $bin.list.fmt('%c', '');
	}

	method gensalt(Int $rounds = 12) returns Str {
		# lower limit is log2(2**4 = 16) = 4
		# upper limit is log2(2**31 = 2147483648) = 31
		die "rounds must be between 4 and 31"
			unless $rounds ~~ 4..31;

		my $salt = rand_chars();
		return crypt_gensalt('$2a$', $rounds, $salt, 128);
	}

	method hash(Str $password, Str $salt) returns Str {
		# bcrypt limits passwords to 72 characters
		return crypt($password.substr(0, 72), $salt);
	}

	method compare(Str $password, Str $hash) returns Bool {
		return Crypt::Bcrypt.hash($password, $hash)
		eq $hash;
	}
}

# vim: ft=perl6
