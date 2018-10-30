use v6;
use Math::ThreeD::Vec3;
use Test;

multi sub is-approx(Vec3 $v1, Vec3 $v2, $desc?) {
    if length(Vec3.new($v2[0] - $v1[0], $v2[1] - $v1[1], $v2[2] - $v1[2])) < 1e-6 {
        ok True, $desc;
    } else {
        ok False, $desc;
        say "    Expected: { $v2.perl }";    
        say "         Got: { $v1.perl }";    
    }
}

isa-ok Vec3.new(1.0, 0.0, 0.0), Vec3, "Can make a Vec3 with new";
ok (length(Vec3.new(1.0, 2.0, 3.0)) - 14.sqrt) < 1e-10, "length works";
ok (length(Vec3.new(5.0, 4.0, 2.0)) - 45.sqrt) < 1e-10, "length works";
is-approx Vec3.new(1.0, 0.0, 0.0), Vec3.new(1.0, 0.0, 0.0), "is-approx works";
is-approx Vec3.new(1.0, 2.0, 4.0), Vec3.new(1.0, 2.0, 4.0), "is-approx works";

my $v1 = Vec3.new(1, 2, 3);
my Vec3 $v2 = Vec3.new(3, 4, 0);
my @v3 = (-1, 0, 2);
my Vec3 $v3 = Vec3.new(@v3);
my Vec3 $origin3d = Vec3.new(0, 0, 0);

is $v1[0], 1, "Vector creation x correct";
is $v1[1], 2, "Vector creation y correct";
is $v1[2], 3, "Vector creation z correct";

# precompiled operator overloading bug is still being investigated
#is-approx $v1 + $v2, Vec3.new(4, 6, 3), "Basic sum works";
#is-approx $v1 + $v2, $v2 + $v1, "Addition is commutative";
#is-approx ($v1 + $v2) + $v3, $v1 + ($v2 + $v3), "Addition is associative";
#is-approx $v1 + $origin3d, $v1, "Addition with origin leaves original";
is-approx $v1.add($v2), Vec3.new(4, 6, 3), "Basic sum works";
is-approx $v1.add($origin3d), $v1, "Addition with origin leaves original";

done-testing;
