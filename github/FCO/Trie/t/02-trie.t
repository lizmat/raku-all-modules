use Trie;
use Test;

my Trie $t1 .= new;
isa-ok $t1, Trie;

is $t1.elems, 0;

my $node = $t1.insert: "bla", 1;
isa-ok $node, Trie;

is $t1.elems, 1;

is $t1.get-node("bla"), $node;
is $t1.get-node("none"), Trie;
is $node.value, 1;

is $t1.elems, 1;

is $t1.single, 1;
is $t1.all, [1];

$t1.insert: "none", 4;
throws-like { $t1.single }, X::Trie::MultipleValues;

is $t1.elems, 2;

is $t1.all, [1, 4];

$t1.insert: "ble", 2;
$t1.insert: "bli", 3;

is $t1.all, [1, 2, 3, 4];

is $t1.get-single("ble"),   2;
is $t1.get-all("bl"),       [1, 2, 3];

is $t1.insert("test").value, "test";
is $t1.get-single("t"), "test";

my @path = $t1.get-path: "test";
is @path.elems, 5;
is @path, [$t1, $t1.get-node("t"), $t1.get-node("te"), $t1.get-node("tes"), $t1.get-node("test")];

is $t1.elems, 5;
$t1.delete: "ble";
is $t1.elems, 4;
is $t1.all, [1, 3, 4, "test"];

$t1.insert: "blah";
is $t1.elems, 5;
$t1.delete: "bla";
is $t1.elems, 4;
is $t1.all, ["blah", 3, 4, "test"];

is $t1<bla>, $t1.get-all: "bla";
for <b bl bla bli blah t te test none> -> \key {
    ok $t1{key}:exists, "{key} exists?";
    is $t1{key}, $t1.get-all: key;
}

for <c cl cla ble> -> \key {
    ok $t1{key}:!exists, "{key} doesn't exists?";
    is $t1{key}, $t1.get-all: key;
}

is $t1<bla>:k, "bla";
is $t1<bla>:v, $t1.get-all: "bla";
is $t1<bla>:kv, ("bla", $t1.get-all: "bla");
is $t1<bla>:p, "bla" => $t1.get-all: "bla";

my $babaca    = $t1.insert: "babaca";
my $cacau     = $t1.insert: "cacau";
my $abacaxi   = $t1.insert: "abacaxi";
my $abacate   = $t1.insert: "ababacate";
my $abocanhar = $t1.insert: "abocanhar";
my $babao     = $t1.insert: "babao";

is $t1.find-char("a").elems, 13;
is $t1.find-substring("bac").sort, <ababacate abacaxi babaca>;

is $t1.find-fuzzy("bct"), set < ababacate >;

is $t1.elems, 10;

is $t1[0], "ababacate";
is $t1[1], "abacaxi";
is $t1[*-1], "test";
is $t1[999], Any;

ok $t1[0]:exists;
ok $t1[1]:exists;
ok $t1[9]:exists;
ok $t1[10]:!exists;
ok $t1[11]:!exists;

done-testing
