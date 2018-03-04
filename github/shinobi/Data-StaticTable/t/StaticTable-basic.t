use v6;
use Test;
use Data::StaticTable;

#===============================================================================
diag "== Basic tests ==";

throws-like
{ my $ = Data::StaticTable.new(<a a b>, (1 .. 6)) },
X::Data::StaticTable,
"Can not create Data::StaticTables with repeated header names";

throws-like
{ my $ = Data::StaticTable.new((), (1 .. 6)) },
X::Data::StaticTable,
"Can not create Data::StaticTables with an empty header";

throws-like
{ my $ = Data::StaticTable.new(1, ()) },
X::Data::StaticTable,
"Can not create Data::StaticTables with empty data";

my $t1 = Data::StaticTable.new(
    10,       # 10 nameless columns. Named automatically as 'A', 'B', etc.
    (1 .. 10) # 10 cells with data, one row
);
diag $t1.display;
ok($t1.header ~~ <A B C D E F G H I J>, "Column names are automatically filled");
ok($t1.ci{'A'} == 1, "Column 1 is automatically labeled 'A'");
ok($t1.ci{'E'} == 5, "Column 5 is automatically labeled 'E'");
ok($t1.rows == 1, "StaticTable has one row only");
ok($t1.elems == 10, "StaticTable contains 10 elements");
#===============================================================================
diag "== Adding empty cells when data is not enough ==";
my $t2 = Data::StaticTable.new(
    10,       # 10 nameless columns. Named automatically as 'A', 'B', etc.
    (1 .. 11) # More than 10 elements. Creates a row almost empty
);
diag $t2.display;
ok($t2.columns == 10, "Data::StaticTable t2 has 10 columns");
ok($t2.rows == 2, "Data::StaticTable t2 has 2 rows");
ok($t2.cell('C', 2) ~~ Any, "Filler cell in 'C',2 is Any element");
ok($t2.elems == 20, "StaticTable contains 20 elements (11 + extra 9)");

#===============================================================================
diag "== Referencing individual cells ==";
my $t3 = Data::StaticTable.new(
    <Col1 Col2 Col3>,
    (
    1, 2, 3,               # Row 1
    "four", "five", "six", # Row 2
    Any, Nil, "NINE"       # Row 3
    )
);
diag $t3.display;
ok($t3.cell('Col3',1) == 3, "Reading a cell directly");
ok($t3.cell('Col1',3).defined == False, "Asking for undefined cell assigned Any");
ok($t3.cell('Col2',3).defined == False, "Asking for undefined cell assigned Nil");
ok($t3.cell('Col3',3).defined == True, "Asking for defined cell");
dies-ok
{ $t3.cell('Col999', 2) },
"Can not access with an inexistant column";
dies-ok
{ $t3.cell('Col1', 4) },
"Can not access with an inexistant row";



#===============================================================================
diag "== Reading cells, rows and columns ==";
my $t4 = Data::StaticTable.new(
  <A  B   C>,  # Header with 3 columns and 66 elements of data
  ( #Columns
  1,  2,  3,  #Row 1
  4,  5,  6,  #Row 2
  7,  8,  9,  #Row 3
  10, 11, 12, #Row 4
  13, 14, 15, #Row 5
  16, 17, 18, #Row 6
  19, 20, 21, #Row 7
  22, 23, 24, #Row 8
  25, 26, 27, #Row 9
  28, 29, 30, #Row 10
  31, 32, 33, #Row 11
  34, 35, 36, #Row 12
  37, 38, 39, #Row 13
  40, 41, 42, #Row 14
  43, 44, 45, #Row 15
  46, 47, 48, #Row 16
  49, 50, 51, #Row 17
  52, 53, 54, #Row 18
  55, 56, 57, #Row 19
  58, 59, 60, #Row 20
  61, 62, 63, #Row 21
  64, 65, 66) #Row 22
);
diag $t4.display;
ok($t4.header ~~ <A B C>, "StaticTable has the correct header");
ok($t4.columns == 3, "StaticTable has 3 columns");
ok($t4.ci{'B'} == 2, "StaticTable second column has the header name 'B'");
ok($t4.ci{'Z'} ~~ Any, "StaticTable has no column with the header name 'Z'");
ok($t4.rows == 22, "StaticTable has 22 rows");
ok($t4.column("A") ~~ (1, 4 ... 64).list, "Column has the correct data in the 'A' column");
ok($t4.cell('C', 1) == 3, "Correct value found in t3 at 'C',1");
ok(35 eq $t4.cell('B', 12), "Correct value found at 'B',12");
ok((4,5,6) ~~ $t4.row(2) , "Correct row number 2 found");
ok($t4.header.elems == 3, "Header has 3 elements");


diag "== Indexes, Generating a new table from a number (index) of rows ==";
my $t5 = Data::StaticTable.new(
    <UID Type Color Price>,
    (
        1402, "Car",  "white", 100,
        1403, "Car",  "blue",  200,
        1404, 'Boat', "white", 3000
    )
);
diag $t5.display;
my %t5-iType = $t5.generate-index("Type");
my %t5-iColor = $t5.generate-index("Color");
diag "Index based on Type:  " ~ %t5-iType.perl;
diag "Index based on Color: " ~ %t5-iColor.perl;
ok(%t5-iType{'Car'} ~~ (1, 2), "Type 'Car' is in rows 1 and 2");
ok(%t5-iColor{'white'} ~~ (1, 3), "Color 'white' is in rows 1 and 3");
#-- Generate a StaticTable where there are only Type = 'Cars'
my $t5-colorwhiteonly = $t5.take(%t5-iColor{'white'});
diag "== Resulting StaticTable with only Color='white' ==";
diag $t5-colorwhiteonly.display;
ok($t5-colorwhiteonly.rows == 2, "Resulting table has 2 rows");
ok($t5-colorwhiteonly.cell('Type', 2) eq 'Boat', "Resulting table has a Boat in the 2nd row");
#-- Trying to generate an empty table from a list of row numbers
my Data::StaticTable::Position @empty-rownum-list = ();
throws-like
{ my $ = $t5.take(@empty-rownum-list) },
X::Data::StaticTable,
"Can not create Data::StaticTables from an empty rownumber list";

my Data::StaticTable::Position @wrong-rownum-list = (1,2,100); #-- There is no row 100
throws-like
{ my $ = $t5.take(@wrong-rownum-list) },
X::Data::StaticTable,
"Can not create Data::StaticTables from an invalid rownumber list";

diag "== Complex cells and shaped arrays ==";
my $t10 = Data::StaticTable.new(
     <Attr          Dim1   Dim2    Dim3    Dim4>, #--   <- Header
    (
    'attribute-1',  1,      2,      3,      'D+', # Row 1
    'attribute-2',  4,      5,      6,      'B+', # Row 2
    'attribute-3',  7,      8,      9,      'A-', # Row 3
    'attribute-4', ('ALPHA',                      # \\\\\
                    'BETA',                       # Row 4
                     3.0),  5,      6,      'A++',# \\\\\
    'attribute-10', 0,      0,      0,      'Z',  # Row 5
    'attribute-11', (-2 .. 2), Nil, Nil,    'X'   # Row 6
    )
);
diag $t10.display;
ok($t10.columns == 5, "StaticTable has 5 columns");
ok($t10.header.elems == 5, "StaticTable has 5 elements in header");
ok($t10.rows == 6, "StaticTable has 6 rows");

my %t10-row1 = (:Attr("attribute-1"), :Dim1(1), :Dim2(2), :Dim3(3), :Dim4("D+"));
my %t10-row4 = (:Attr("attribute-4"), :Dim1($("ALPHA", "BETA", 3.0)), :Dim2(5), :Dim3(6), :Dim4("A++"));

ok($t10[1] ~~ %t10-row1, "Reading rows by number returns the right hash for the row - row number 1");
ok($t10[4] ~~ %t10-row4, "Reading rows by number returns the right hash for the row - row number 4, complex");
ok($t10[4]<Dim1>[0] eq 'ALPHA', "Can read complex data inside a cell  - row number 4");
ok($t10.cell("Dim1", 6) ~~ (-2 .. 2), "Can read complex data inside a cell - row number 6");
ok($t10.cell("Dim1", 6) ~~ (-2 .. 2), "Can read complex data inside a cell - row number 6");
ok($t10[1]<Dim1> ~~ $t10.cell("Dim1", 1), "Equivalent ways to read the same cell");

diag "== Resulting StaticTable with only Dim2=5 ==";
my %t10-iDim2 = $t10.generate-index("Dim2");
diag %t10-iDim2{5}.perl;
diag %t10-iDim2<5>.perl;
my $t10-Dim2is5 = $t10.take(%t10-iDim2<5>);
diag $t10-Dim2is5.display;
ok($t10-Dim2is5.rows == 2, "Resulting table has 2 rows too");
ok($t10-Dim2is5[2]<Dim1>[1] eq 'BETA', "Can read complex data inside a cell  - row number 2 of resulting table");

diag "== Shaped array ==";
my @shape = $t10.shaped-array();
ok (@shape[3;1;0] eq 'ALPHA', "Shape spec works as expected (3 dimensions)");
ok (@shape[3;1;1] eq 'BETA', "Shape spec works as expected (3 dimensions)");
ok (@shape[3;1;2] == 3, "Shape spec works as expected (3 dimensions)");
ok (@shape[1;2] == 5, "Shape spec works as expected (2 dimensions)");

done-testing;
