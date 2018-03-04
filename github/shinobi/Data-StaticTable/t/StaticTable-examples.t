use v6;
use Test;
use Data::StaticTable;

ok(1==1, "Example code");

# == Basic examples of use ==
my $t1 = Data::StaticTable.new(
   <Col1    Col2     Col3>,
   (
   1,       2,       3,      # Row 1
   "four",  "five",  "six",  # Row 2
   "seven", "eight", "none", # Row 2
   Any,     Nil,     "nine"  # Row 4
   )
);

say $t1.display; # This will show a visual representation of the StaticTable

say $t1.rows;                # Prints 4
say $t1.columns;             # Prints 3
say $t1.header;              # Prints [Col1 Col2 Col3]
#say $t1[0]<Col2>;            # This will fail, There is NO ROW ZERO
say $t1[1]<Col2>;            # Prints 2
say $t1.cell("Col1", 1); # Prints 1

say $t1.cell("Col1", 4).defined; # Prints False
say $t1.cell("Col2", 4).defined; # Prints False
say $t1.cell("Col3", 4).defined; # Prints True

say $t1[1];         # Prints {Col1 => 1, Col2 => 2, Col3 => 3}
say $t1.row(1); # Prints (1 2 3)

my Data::StaticTable::Position @rowlist = (1,3);
my $t2 = $t1.take( @rowlist ); # $t2 is $t1 but only containing rows 1 and 3

# == Query object use and grep ==
my $t3 = Data::StaticTable.new(
   5,
   (
   "Argentina" , "Bolivia" , "Colombia" , "Ecuador" , "Etiopia"   ,
   "France"    , "Germany" , "Ghana"    , "Hungary" , "Haiti"     ,
   "Japan"     , "Kenia"   , "Italy"    , "Morocco" , "Nicaragua" ,
   "Paraguay"  , "Peru"    , "Quatar"   , "Rwanda"  , "Singapore" ,
   "Turkey"    , "Uganda"  , "Uruguay"  , "Vatican" , "Zambia"
   )
);
my $q3 = Data::StaticTable::Query.new($t3); # Query object
say $t3.header; # Prints [A B C D E]
$q3.add-index('A'); # Searches (grep) on column A will be faster now

# == Rows with a column A that has 'e' AND 'n', at the same time ==
my Data::StaticTable::Position @r1 = $q3.grep(all(rx/n/, rx/e/), 'A'):n; # Rows 1 and 2

# == Rows with a column C that has 'y' ==
my Data::StaticTable::Position @r2 = $q3.grep(rx/y/, 'C'):n; # Rows 3 and 5
my $t4 = $t3.take(@r2); # Table $t4 is $t3 with rows 3 and 5 only
say $t4.display;  # Display contents of $t4

# == grep modes ==
say $q3.grep(rx/Peru/, 'B');   # Default grep mode, :h
# Displays [B => Peru A => Paraguay E => Singapore D => Rwanda C => Quatar]

say $q3.grep(rx/Peru/, 'B'):n; # :n only get the number of the matching rows
# Displays (4)

say $q3.grep(rx/Peru/, 'B'):r; # r: returns the array of the data, no headers
# Displays [Paraguay Peru Quatar Rwanda Singapore]


done-testing;
