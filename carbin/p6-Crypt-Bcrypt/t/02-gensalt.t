use v6;
use Crypt::Bcrypt;
use Test;

plan 65;

my Crypt::Bcrypt $bc .= new();

loop (my Int $round = 4; $round <= 31; $round++) {
	my $gen = Crypt::Bcrypt.gensalt($round);
	 # 7 prefix + 22 encoded salt
	is $gen.chars, 29, 'count for ' ~ $round;
	is $gen.substr(0, 7), '$2a$'
		~ $round.Str.fmt('%02d') ~ '$',
		'prefix for ' ~ $round ~ ' rounds';
}

dies-ok { $bc.gensalt(-20) }, 'dies with negative rounds';
dies-ok { $bc.gensalt(-1) }, 'dies with negative rounds';
dies-ok { $bc.gensalt(0) }, 'dies with 0 rounds';
dies-ok { $bc.gensalt(1) }, 'dies with 1 round';
dies-ok { $bc.gensalt(2) }, 'dies with 2 rounds';
dies-ok { $bc.gensalt(3) }, 'dies with 3 rounds';
lives-ok { $bc.gensalt(4) }, 'lives with 4 rounds';
lives-ok { $bc.gensalt(31) }, 'lives with 31 rounds';
dies-ok { $bc.gensalt(32) }, 'dies with 32 rounds';

# vim: ft=perl6
