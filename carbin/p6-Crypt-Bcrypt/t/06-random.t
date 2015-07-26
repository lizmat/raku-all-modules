use v6;
use Test;
use Crypt::Bcrypt;

plan 150;

sub rchars returns Str {
	my $f = open('/dev/urandom');
	my $c = (1..72).pick(1);
	my $bin = $f.read($c);
	$f.close();
	return $bin.list.fmt('%c', '');
}

my Int $difficulty = 12;
$difficulty = %*ENV<MAX_DIFFICULTY>.Int if %*ENV<MAX_DIFFICULTY>.defined;

for (1..50) {
	my Str $r = rchars();
	my Int $c = (4..$difficulty).pick;
	my Str $h = Crypt::Bcrypt.hash($r, Crypt::Bcrypt.gensalt($c));
	is Crypt::Bcrypt.hash($r, $h), $h, 'random hash matches, cost: ' ~ $c;

	# $2a$12$upXWXCP1u4pBez1ArqIRX.TBg1Hb5yKgGY3aLdv0JyppifYqLNIQC
	is $h.substr(0, 4), '$2a$', 'prefix is correct';
	is $h.substr(4, 3), sprintf('%02d$', $c), 'cost, ' ~ $c ~ ', is correct';
}

# vim: ft=perl6
