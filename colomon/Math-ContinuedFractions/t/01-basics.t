use v6;
use Test;
use Math::ContinuedFraction;

my @rationals = 3 => [3],
                0 => [0],
                -42 => [-42],
                3.245 => [3, 4, 12, 4],
                -4.2 => [-5, 1, 4];
                
for @rationals>>.kv -> $rational, $cf-form {
    my $cf = Math::ContinuedFraction.new($rational);
    isa_ok $cf, Math::ContinuedFraction, "We made a Math::ContinuedFraction object for $rational";
    is $cf.a, $cf-form, "With the correct value";
    my $cf2 = Math::ContinuedFraction.new($cf.a);
    isa_ok $cf2, Math::ContinuedFraction, "We created a Math::ContinuedFraction object by array";
    is $cf2.a, $cf-form, "Still with the correct value";
    my $cf3 = Math::ContinuedFraction.new($cf);
    isa_ok $cf3, Math::ContinuedFraction, "We copied Math::ContinuedFraction object using .new";
    is $cf3.a, $cf-form, "Still has the correct value";
}

my $three = Math::ContinuedFraction.new(3);
my $two = Math::ContinuedFraction.new(2);
is ($three + $two).a, Math::ContinuedFraction.new(5).a, "3 + 2 == 5";
is $three.a, [3], "Didn't consume 3";
is $two.a, [2], "or 2";

is ($three + 3.2345234).a, Math::ContinuedFraction.new(6.2345234).a, "3 + 3.2345234 == 6.2345234";
is (3.2345234 + $two).a, Math::ContinuedFraction.new(5.2345234).a, "3.2345234 + 2 == 5.2345234";

is ($three - $two).a, Math::ContinuedFraction.new(1).a, "3 - 2 == 1";
is $three.a, [3], "Didn't consume 3";
is $two.a, [2], "or 2";

is ($three - 3.2345234).a, Math::ContinuedFraction.new(-0.2345234).a, "3 - 3.2345234 == -0.2345234";
is (3.2345234 - $two).a, Math::ContinuedFraction.new(1.2345234).a, "3.2345234 - 2 == 1.2345234";

is ($three * $two).a, Math::ContinuedFraction.new(6).a, "3 * 2 == 6";
is $three.a, [3], "Didn't consume 3";
is $two.a, [2], "or 2";

is ($three * 3.2345234).a, Math::ContinuedFraction.new(3 * 3.2345234).a, "3 * 3.2345234 == whatever";
is (3.2345234 * $two).a, Math::ContinuedFraction.new(3.2345234 * 2).a, "3.2345234 * 2 == whatever";

is ($three / $two).a, Math::ContinuedFraction.new(3/2).a, "3 / 2 == 3/2";
is $three.a, [3], "Didn't consume 3";
is $two.a, [2], "or 2";

is ($three / 3.2345234).a, Math::ContinuedFraction.new(3 / 3.2345234).a, "3 / 3.2345234 == whatever";
is (3.2345234 / $two).a, Math::ContinuedFraction.new(3.2345234 / 2).a, "3.2345234 / 2 == whatever";

is Math::ContinuedFraction.new(-2.3241).abs.a, Math::ContinuedFraction.new(2.3241).a, '.abs works on negative number';
is Math::ContinuedFraction.new(2.3241).abs.a, Math::ContinuedFraction.new(2.3241).a, '.abs works on positive number';

my @values = # cf => [name, .sign, .truncate, floor, ceiling, round] 
             Math::ContinuedFraction.new(0) => ["0", 0, 0, 0, 0, 0],
             Math::ContinuedFraction.new(0.0001) => ["0.0001", 1, 0, 0, 1, 0],
             Math::ContinuedFraction.new(0.9999) => ["0.9999", 1, 0, 0, 1, 1],
             Math::ContinuedFraction.new(1) => ["1", 1, 1, 1, 1, 1],
             Math::ContinuedFraction.new(1.2313) => ["1.2313", 1, 1, 1, 2, 1],
             Math::ContinuedFraction.new(34) => ["34", 1, 34, 34, 34, 34],
             Math::ContinuedFraction.new(403.1) => ["403.1", 1, 403, 403, 404, 403],
             Math::ContinuedFraction.new(-0.0001) => ["-0.0001", -1, 0, -1, 0, 0],  
             Math::ContinuedFraction.new(-0.9999) => ["-0.9999", -1, 0, -1, 0, -1],  
             Math::ContinuedFraction.new(-1) => ["-1", -1, -1, -1, -1, -1], 
             Math::ContinuedFraction.new(-1.2313) => ["-1.2313", -1, -1, -2, -1, -1],
             Math::ContinuedFraction.new(-34) => ["-34", -1, -34, -34, -34, -34],
             Math::ContinuedFraction.new(-403.1) => ["-403.1", -1, -403, -404, -403, -403];

for @values>>.kv -> $cf, [$name, $sign, $truncate, $floor, $ceiling, $round] {
    isa_ok $cf, Math::ContinuedFraction, "$name is a ContinuedFraction";
    is $cf.sign, $sign, "$name .sign is $sign";
    isa_ok $cf.sign, Int, "$name .sign is Int";
    is $cf.truncate, $truncate, "$name .truncate is $truncate";
    isa_ok $cf.truncate, Int, "$name .sign is Int";
    is $cf.floor, $floor, "$name .floor is $floor";
    isa_ok $cf.floor, Int, "$name .sign is Int";
    is $cf.ceiling, $ceiling, "$name .ceiling is $ceiling";
    isa_ok $cf.ceiling, Int, "$name .sign is Int";
    is $cf.round, $round, "$name .round is $round";
    isa_ok $cf.round, Int, "$name .sign is Int";
}

done;
