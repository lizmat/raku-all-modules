use v6;
use Test;
use Data::StaticTable;

diag "== Extra features tests ==";
my $t1 = Data::StaticTable.new(
  <A B C>,
  (1 .. 9)
);
diag $t1.display;
diag "== Serialization and EVAL test ==";
my $t1-copy = EVAL $t1.perl;
diag $t1-copy.perl;
diag "== Comparison test ==";
my $t1-clone = $t1.clone();
my $t2 = Data::StaticTable.new(
  <A B C>,
  (1,2,3,4,5,6,7,0,9) # The 0 before the 9 is the only difference
);
ok($t1 eqv $t1-copy, "Comparison works (equal to EVALuated copy from 'perl' method)");
ok($t1 eqv $t1-clone, "Comparison works (equal to clone)");
ok(($t1 eqv $t2) == False, "Comparison works (distinct)");

diag "== Filler tests ==";
my $t3 = Data::StaticTable.new(
  <A B C>,
  (1,2,3,
   4,5,6,
   7),     # 2 last shoud be fillers
   filler => 'N/A'
);
diag $t3.display;
ok($t3[3]<C> eq 'N/A', 'Filler is correct');
my $t3-clone = $t3.clone();
ok($t3 eqv $t3-clone, "Cloning with filler works");

diag "== 'take' using Int and Position types ==";
my Data::StaticTable::Position @rowset13 = (1,3);
my $t31 = $t3.take(@rowset13);
my $t32 = $t3.take([1, 3]);
my $t33 = $t3.take(1, 3);
ok($t31 eqv $t32, "'take' works correcly using Ints or Position types #1");
ok($t31 eqv $t33, "'take' works correcly using Ints or Position types #2");

my Data::StaticTable::Position @rowset3 = (3);
my $t34 = $t3.take(@rowset3);
my $t35 = $t3.take(3);
ok($t34 eqv $t35, "'take' works correcly using Ints or Position types (list of 1 element)");

done-testing;
