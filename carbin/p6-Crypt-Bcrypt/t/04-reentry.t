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

my @chars = @('a'..'z', 0..9).flat;
@chars .= pick(*);

sub addchars(int $many) returns Str {
	@chars .= pick(*);
	my $ret = @chars.roll($many).join;
	if $ret.chars ne $many {
		die "addchars: returned more characters than asked for " ~
			"{$ret.chars} vs {$many}";
	}
	return $ret;
}


loop (my Int $round = 4; $round < 15; $round++) {
	my $password = addchars((1..99).pick);
	my $hash = Crypt::Bcrypt.hash($password, $round);

	is $hash, Crypt::Bcrypt.hash($password, $hash),
		'reusing hash as salt-settings works';
}

my $hash = Crypt::Bcrypt.hash('My secret password 123');

is $hash, Crypt::Bcrypt.hash('My secret password 123', $hash), 'validation';
isnt $hash, Crypt::Bcrypt.hash('Let me in 123', $hash), 'correctly fails';

# vim: ft=perl6
