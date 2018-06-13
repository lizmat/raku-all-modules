use Test;
use-ok "OrderedHash";
use OrderedHash;

my %oh does OrderedHash[:keys<a b c>];

is %oh.keys, ();

is %oh.values, ();

is %oh.elems, 0;

is (%oh<c> = 42), 42;

is %oh.keys, <c>;

is %oh.values, (42);

is %oh.elems, 1;

is (%oh<c> = ^10), ^10;

is %oh.values, (^10);

is (%oh<b> = {:1a}), {:1a};

is %oh.keys, <b c>;

is %oh.values, ({:1a}, ^10);

lives-ok {%oh<a> // 10};

throws-like { %oh<d> = 1 }, X::TypeCheck::Binding::Parameter;

my %oh2 does OrderedHash[:keys<2 3 1>] = 1 => 3, 2 => 1, 3 => 2;

is %oh2.keys, <2 3 1>;

is %oh2.values, <1 2 3>;

is %oh2.kv, <2 1 3 2 1 3>;

is %oh2.pairs, (2 => 1, 3 => 2, 1 => 3);

my %oh3 does OrderedHash[Int];

dies-ok {%oh3<error> = "string"};

done-testing
