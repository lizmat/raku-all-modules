use Test;

use Operator::grandpa;

plan 5;

class Node {
  has $.name;
  has $.parent;
}

my $child = Node.new(
  :name("out"),
  :parent( Node.new(
    :name("mid"),
    :parent( Node.new(
      :name("inner"),
      :parent( Node.new( :name("root") ) )
    ))
  ))
);

my $root = $child :| { .parent }
ok $root.name ~~ "root";

my $root2 = $child :| -> $node { $node.parent }
ok $root2.name ~~ "root";

my $a = 1;
ok $a 𝄇 { $++ > 2 ?? Any !! $_ * 2 } == 8;

my $b = 1;
ok $b |: { $_ = 2; Any } == 2;
ok $b == 1;

done-testing;
