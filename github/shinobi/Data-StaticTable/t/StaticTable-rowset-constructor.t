use v6;
use Test;
use Data::StaticTable;

diag "== Rowset constructor tests ==";

my @data-array-list = (
    <ONE  TWO  THREE FOUR>,
    (1,   2,   3),            # Row 1
    (1,   2,   3,    4),      # Row 2
    (1,   2,   3,    4,   5), # Row 3
    (1,  (2,1))               # Row 4
);

diag "== First row is a header ==";
my $t1 = Data::StaticTable.new(@data-array-list):data-has-header;
diag $t1.display;
ok($t1.rows == 4, "Contains 4 rows");
ok($t1.columns == 4, "Contains 4 colums");
ok($t1[3]<THREE> == 3, "3rd row, column THREE has a 3");
ok($t1[1]<FOUR>.defined == False, "1st row does not have FOUR defined");
ok($t1.row(3).elems == 4, "Extra 5th element in row 3 was discarded");

diag "== First row is NOT a header ==";
my $t2 = Data::StaticTable.new(@data-array-list);
diag $t2.display;
ok($t2.rows == 5, "Contains 5 rows");
ok($t2.columns == 5, "Contains 5 colums");
ok($t2[4]<E> == 5, "3rd row, column E has a 5");
ok($t2[1]<E>.defined == False, "1st row does not have E defined");

throws-like
{ my $ = Data::StaticTable.new(@data-array-list):set-of-hashes:data-has-header },
X::Data::StaticTable,
"Can not create Data::StaticTable with contradictory flags";

my @data-hash-list =
    (10, 20), # This will be discarded since is not a hash
    {color => 'gray',   brand => 'Zubata', model => 'Bronco XS',   nOfDoors => 5, year => 1970,
    ashtrays => 4},                                           # Car 1
    {color => 'yellow', brand => 'Atto',   model => 'Star Hybrid', nOfDoors => 4, year => 2007,
    airbags => 2},                                            # Car 2
    {color => 'yellow', brand => 'Renu',   model => 'City Ranger', nOfDoors => 4, year => 2018,
    airbags => 8, autopilot => 'OpenAI based'},               # Car 3
    {color => 'blue',   brand => 'Astoni', model => '534-Z SPX',   nOfDoors => 2, year => 2018,
    airbags => 4, autopilot => 'Unknown', battery-kWh => 75}  # Car 4
;
diag "== Hash to StaticTable ==";
my $t3 = Data::StaticTable.new(@data-hash-list):set-of-hashes;
diag $t3.display;
ok($t3.rows == 4, "Contains 4 rows");
ok($t3.columns == 9, "Contains 9 colums");
ok($t3[3]<airbags> == 8, "3rd car has 8 airbags");
ok($t3[1]<airbags>.defined == False, "1st car does not have airbags defined");
ok($t3[4]<battery-kWh> == 75, "4th car has a 75kWh battery");

throws-like
{ my $ = Data::StaticTable.new(@data-array-list):set-of-hashes},
X::Data::StaticTable,
"Trying to create a StaticTable from hashes without providing any hash, fails";



diag "== Recovering discarded data ==";
#-- For an array, rejected data is recoverable in the way of a hash.
#-- Note: If you don't use data-has-header, you will not discard anything
my %rejected-array-data;
my $ = Data::StaticTable.new(
    @data-array-list,
    rejected-data => %rejected-array-data
):data-has-header;
diag "== Rejected data by row ==";
diag %rejected-array-data.perl;
ok(%rejected-array-data<3> ~~ (5).list, "For row 3 (considering a header), the value 5 was discarded");

#-- For a hash, rejected data is recoverable in the way of an array
#-- Note: Only rows that are not hashes are discarded
my @rejected-hash-data;
my $ = Data::StaticTable.new(
    @data-hash-list,
    rejected-data => @rejected-hash-data
):set-of-hashes;
diag "== Rejected: rows that are not hashes ==";
diag @rejected-hash-data.perl;
ok(@rejected-hash-data.elems == 1, "One row was rejected");
ok(@rejected-hash-data[0] ~~ (10, 20), "Discarded data as expected");

done-testing;
