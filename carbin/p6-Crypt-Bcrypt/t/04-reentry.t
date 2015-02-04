use v6;
use Test;
use Crypt::Bcrypt;

plan 14;

is Crypt::Bcrypt.hash(
		'',
		'$2a$12$VgRlJiQzRMIXoi7fLnXRWOOkuXydB1qA5ALEoYYNHi55Z0vJxV0GS'
	),
	'$2a$12$VgRlJiQzRMIXoi7fLnXRWOOkuXydB1qA5ALEoYYNHi55Z0vJxV0GS',
	'empty string';

my @chars = @('a'..'z', 0..9);
@chars .= pick(*);

sub addchars(int $many) returns Str {
	@chars .= pick(*);
	return @chars.pick($many).join;
}


loop (my Int $round = 4; $round < 15; $round++) {
	my $salt = Crypt::Bcrypt.gensalt($round);
	my $password = addchars(32);
	my $hash = Crypt::Bcrypt.hash($password, $salt);

	is $hash, Crypt::Bcrypt.hash($password, $hash),
		'reusing hash as salt-settings works';
}

my $hash = Crypt::Bcrypt.hash('My secret password 123',
	Crypt::Bcrypt.gensalt());

is $hash, Crypt::Bcrypt.hash('My secret password 123', $hash), 'validation';
isnt $hash, Crypt::Bcrypt.hash('Let me in 123', $hash), 'correctly fails';

# vim: ft=perl6
