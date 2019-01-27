use Test;
use DBIish;
use DBDish::SQLite;
use DBDish::SQLite::Connection;
use DB::Migration::Simple;

my $verbose = False;

my $dbh = DBIish.connect("SQLite", :database<t/test-db.sqlite3>);

my $m = DB::Migration::Simple.new(:$dbh, :migration-file<t/migrations> :$verbose);
isa-ok $m.dbh, DBDish::SQLite::Connection, "dbh installed in DB::Migration::Simple";
ok $m.migration-file.IO.e, "migrations file exists";

is $m.current-version, 0, 'current version is 0';

is $m.migrate(:version<0>), 0, 'already at version 0';

# go to version 1
is $m.migrate(:version<1>), 1, 'going to version 1';

# check table made, content inserted
is-deeply select('SELECT * from table_version_1'), [[1, "This is version 1"],], 'table version 1 populated';
nok $!, "no error occurred querying table_version_1";

# go to version 3
is $m.migrate(), 3, 'going to latest version (3)';
is-deeply select('SELECT * from table_version_2'), [["This is version 2"],], 'table version 2 populated';
is-deeply select('SELECT * from table_version_3'), [], 'table version 3 populated';

# go back to version 2
ok $m.migrate(:version<2>) eq '2', 'going back to version 2';
check-table-gone(3);

# go to version 0
ok $m.migrate(:version<0>) eq '0', 'going back to version 0';
check-table-gone(2);
check-table-gone(1);

done-testing;

sub select($stmt) {
    my $sth = $dbh.prepare($stmt);
    $sth.execute();
    my @rows = $sth.allrows();
    $sth.finish();
    return @rows;
}

sub check-table-gone($number) {
    throws-like {select("SELECT * from table_version_$number")}, X::DBDish::DBError, "table version $number gone";
}
