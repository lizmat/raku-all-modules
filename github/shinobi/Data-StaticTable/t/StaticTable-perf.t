use v6;
use Test;
use Data::StaticTable;

my Real $TIME;

my $CSV1 = "t/fao-sample.csv";
my $CSV2 = "t/FL_insurance_sample-UNIX.csv";

#------------------------------------------------------------------------------#

diag "== Reading a sample file in a StaticTable ==";
#-- This is not a safe way to read CSVs. Look for an appropiate
#-- CSV library for this.
my @csv1 = $CSV1.IO.lines;
my @header1 = @csv1.shift.split(',');
my @data1 = @csv1.map(*.split(',')).flat;
$TIME = now;
my $t1 = Data::StaticTable.new(@header1, @data1);
$TIME = now - $TIME;
#diag $t1.display;
diag "== Populate StaticTable took : $TIME secs. ==";

diag "== Discarding rows with aggregation data ==";
my Data::StaticTable::Position @rows-with-raw-data = (1 .. 16);
$TIME = now;
my $t1-rawdata = $t1.take(@rows-with-raw-data);
$TIME = now - $TIME;
diag "== Creation of sub-StaticTable took : $TIME secs. ==";
my Real $time-per-row = ($TIME / 16).round(0.00000001);
diag "==    Time per row : $time-per-row secs. ==";

ok($t1-rawdata.rows == 16, "Got the right number of rows");

diag "== Reading a big sample file in a StaticTable ==";
my @csv2 = $CSV2.IO.lines;
diag "== File now in memory. Creating array ==";
my @header2 = @csv2.shift.split(',');
my @data2 = @csv2.map(*.split(',')).flat;
diag "== Data array created : " ~ @data2.elems ~ " total elements ==";
$TIME = now;
my $t2 = Data::StaticTable.new(@header2, @data2);
$TIME = now - $TIME;
#diag $t2.display;
diag "== Populate StaticTable took : $TIME secs. ==";
diag "== Total rows : " ~ $t2.rows ~ " ==";
my Real $time-sum = 0;
my Real @time-results-per-set = ();
my Real @time-results-per-row = ();

my Int $rows-per-set = 100;
my Int $number-of-sets = ($t2.rows / 100).round;
diag "== Sub-tables stress tests starting : $number-of-sets rowsets, 100 rows per set ... ==";
for (1 .. $number-of-sets) -> $set {
    my $start = (($set - 1) * $rows-per-set) + 1;
    my $end = (($set - 1) * $rows-per-set) + $rows-per-set;
    next if ($end > $t2.rows); #-- Sample is smaller, discard.
    my Data::StaticTable::Position @rowset = ($start .. $end);
    $TIME = now;
    my $tsub = $t2.take(@rowset);
    $TIME = now - $TIME;
    push @time-results-per-row, $TIME / 100;
};
my Real $time-avg-row = (([+] @time-results-per-row)/$number-of-sets).round(0.00000001);
diag "== Average : $time-avg-row secs. per row ==";

diag "== Index speed ==";
my $q1 = Data::StaticTable::Query.new($t2);
my $q2 = Data::StaticTable::Query.new($t2);

$TIME = now;
  my $score-county = $q1.add-index("county").round(0.0001);
$TIME = now - $TIME;
diag "== Index creation 'county' took : $TIME secs. ==";

$TIME = now;
  $q1.grep(/CLAY/, "county"):n;
$TIME = now - $TIME;
diag "== Search with index (scored $score-county) took : $TIME secs. ==";

$TIME = now;
  $q2.grep(/CLAY/, "county"):n;
$TIME = now - $TIME;
diag "== Search without index took : $TIME secs. ==";

$TIME = now;
  my $score-policyID = $q1.add-index("policyID").round(0.0001);
$TIME = now - $TIME;
diag "== Index creation 'policyID' took : $TIME secs. ==";
$TIME = now;
  $q1.grep(/167630/, "policyID"):n;
$TIME = now - $TIME;
diag "== Search with index (scored $score-policyID) took : $TIME secs. ==";
$TIME = now;
  $q2.grep(/167630/, "policyID"):n;
$TIME = now - $TIME;
diag "== Search without index took : $TIME secs. ==";

ok(
    ($q1.grep(/167630/, "policyID"):n)
    ~~
    ($q2.grep(/167630/, "policyID"):n),
    "Grep with index and without are equivalent"
);

diag "== Cloning ==";
$TIME = now;
my $t2-clone = $t2.clone();
$TIME = now - $TIME;
diag "== Cloning a big StaticTable took : $TIME secs. ==";

diag "== Comparison on a big StaticTable (might take a while...) ==";
$TIME = now;
$ = $t2 eqv $t2-clone;
$TIME = now - $TIME;
diag "== Comparing 2 big equal StaticTables took : $TIME secs. ==";

done-testing;
