use v6;
use Test;
use Data::StaticTable;

diag "== Testing indexes ==";
my $t1 = Data::StaticTable.new(
     <Attr          Dim1      Dim2    Dim3    Dim4>,
    (
    'attribute-1',  1,         21,     3,      'D+', # Row 1
    'attribute-2',  4,         51,     6,      'B+', # Row 2
    'attribute-3',  7,         80,     9,      'A-', # Row 3
    'attribute-4', ('ALPHA',                         # \\\\\
                    'BETA',                          # Row 4
                     3.0),     5,      6,      'A++',# \\\\\
    'attribute-10', 0,         0,      0,      'B+', # Row 5
    'attribute-11', (-2 .. 2), Nil,    Nil,    'B+'  # Row 6
    )
);
diag $t1.display;

diag "== Check indexes ==";
my $q1  = Data::StaticTable::Query.new($t1, $t1.header);

ok($q1<Dim4>.elems == 4, "Index of Dim4 has 4 elements");
ok($q1<Dim1>:exists == True, "We can check if a column index has been generated");
ok($q1<DimX>:exists == False, "We can check if a column index has not been generated");
ok($q1<Dim1><7>:exists == True, "We can see if the value 7 exists in a indexed column");
ok($q1<Dim1><9>:exists == False, "We can see if the value 9 does not exist in a indexed column");
ok($q1<Dim3><6>.elems == 2, "We can check that the value 6 appears in 2 rows in column Dim3");
ok($q1<Dim3><6> ~~ (2, 4), "We can check that the value 6 appears in column Dim3, rows 2 and 4");

diag "== Searching without index ==";
my $q2 = Data::StaticTable::Query.new($t1);
ok($q2.grep(rx/6/, "Dim3"):n                 ~~ (2, 4),    "Grep test returns rows 2,4");
ok($q2.grep(any(rx/9/, rx/6/), "Dim3"):n     ~~ (2, 3, 4), "Grep test returns rows 2,3,4" );
ok($q2.grep(one(rx/1/, rx/5/), "Dim2"):n     ~~ (1, 4),    "Grep test returns rows 1,4");
ok($q2.grep(any(rx/1/, rx/5/), "Dim2"):n     ~~ (1, 2, 4), "Grep test returns rows 1,2,4");
ok($q2.grep(all(rx/1/, rx/5/), "Dim2"):n     ~~ (2,),      "Grep test returns row 2");
ok($q2.grep(none(rx/1/, rx/5/), "Dim2"):n    ~~ (3, 5),    "Grep test returns rows 3,5");
ok($q2.grep(any(rx/ALPHA/, rx/0/), "Dim1"):n ~~ (4, 5, 6), "Grep test returns rows 4,5,6");

ok(
    ($q1.grep(any(rx/1/, rx/5/), "Dim2"):n) ~~ ($q2.grep(any(rx/1/, rx/5/), "Dim2"):n),
    "Grep with index and without are equivalent (#1)"
);

ok(
    ($q1.grep(all(rx/1/, rx/5/), "Dim2"):n) ~~ ($q2.grep(all(rx/1/, rx/5/), "Dim2"):n),
    "Grep with index and without are equivalent (#2)"
);

ok(
    ($q1.grep(none(rx/1/, rx/5/), "Dim2"):n) ~~ ($q2.grep(none(rx/1/, rx/5/), "Dim2"):n),
    "Grep with index and without are equivalent (#3)"
);

diag "== Check different grep modes ==";
my $rx = any(rx/ALPHA/, rx/0/);
diag $q1.grep($rx, "Dim1"):n.perl;
ok (($q1.grep($rx, "Dim1"):n) ~~ (4,5,6), "Expected rows");

diag $q1.grep($rx, "Dim1"):r.perl;
ok($q1.grep($rx, "Dim1"):r.elems == 3, "Expected 3 rows");

diag $q1.grep($rx, "Dim1"):h.perl;
ok($q1.grep($rx, "Dim1"):h.elems == 3, "Expected 3 rows");

diag $q1.grep($rx, "Dim1"):nr.perl;
ok (($q1.grep($rx, "Dim1"):nr.keys) ~~ (4,5,6), "Expected rows indexes");

diag $q1.grep($rx, "Dim1"):nh.perl;
ok (($q1.grep($rx, "Dim1"):nh.keys) ~~ (4,5,6), "Expected rows indexes");

diag "== Create a new table from grep results of row numbers ==";
my Data::StaticTable::Position @rownums;
@rownums.append( $q2.grep(one(rx/1/, rx/5/), "Dim2"):n );
@rownums.append( $q2.grep(all(rx/1/, rx/5/), "Dim2"):n );

my $t2 = $t1.take(@rownums);
#-- This should generate a StaticTable with rows 1, 4 and 2. IN THAT ORDER.
diag $t2.display;

ok($t2.rows == 3, "Resulting StaticTable has 3 rows");
ok($t2[3]{'Dim2'} == 51, "Right value found in Col Dim2, Row 3");

diag "== Index creation at construction ==";
my Data::StaticTable::Position @two-rows = (1, 2);
my $t3 = $t1.take(@two-rows);
my $q31 = Data::StaticTable::Query.new($t3, <Dim1 Dim2>);
my $q32 = Data::StaticTable::Query.new($t3, 'Dim1', 'Dim2');
ok($q31.kv.perl eqv $q32.kv.perl, "Equivalence using slurpy array for index spec on construction");

throws-like
{ my $ = Data::StaticTable::Query.new($t3, 'Dim1', 'DimXXXXX') },
X::Data::StaticTable,
"Construction fails when specifiying a heading that does not exist";

diag "== Serialization and EVAL test ==";
my $q33 = EVAL $q31.perl;
diag $q33.perl;
ok($q31.perl eq $q33.perl, "Can be serialized using .perl method");

done-testing;
