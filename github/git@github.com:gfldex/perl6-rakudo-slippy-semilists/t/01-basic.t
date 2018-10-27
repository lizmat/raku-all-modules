use v6;
use Test;
use Rakudo::Slippy::Semilist;

plan 11;

my %h;
my @a = 1..3;
%h{||@a} = 42;

is %h{1}{2}{3}, 42, 'chaining subscript';
is %h{1;2;3}, 42, 'semilist literal';
is %h{||@a}, 42, 'prefix:<||>';
is %h{*;*;*}, 42, 'Whatever semilist literal';
ok %h{||@a}:exists, ':exits';
ok %h{1;2;3}:exists, ':exits for literal';

my %oh{Any};
@a = (my $o1 = class :: {}.new, my $o2 = class :: {}.new, my $o3 = class :: {}.new);
%oh{||@a} = 42;

is %oh{$o1;$o2;$o3}, 42, 'semilist literal on object hash';
is %oh{||@a}, 42, 'prefix:<||> on object hash';
is %oh{*;*;*}, 42, 'Whatever semilist literal on object hash';
ok %oh{||@a}:exists, ':exits on object hash';
ok %oh{$o1;$o2;$o3}:exists, ':exits for literal on object hash';

