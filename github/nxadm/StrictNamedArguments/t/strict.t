use v6;
use lib 'lib';
use Test;
use StrictNamedArguments;

plan 4;

class Foo {
	has $.valid;
	# Perl 6 will deal with the positional part, our trait C<is strict>
	# will learn about C<:$valid>.
	method new(:$valid) is strict { self.bless(valid => $valid) }
	method shout(:$msg) is strict { $msg.uc }
}
dies-ok {Foo.new(valid_not_really => True)}, 'Invalid constructor dies';
my $foo = Foo.new(valid => True);
isa-ok($foo, Foo);
is($foo.shout(msg => 'twist'), 'TWIST', 'Valid method input');
dies-ok { $foo.shout(msg_ => 'TWIST')}, 'Invalid method input';
