# postgresql test example 1 translated from C to Perl 6
# See http://www.postgresql.org/docs/9.0/static/libpq-example.html
# and more comments below.

use NativeCall;  # from project 'zavolaj'

# -------- foreign function definitions in alphabetical order ----------

sub PQclear( OpaquePointer $res )
    is native('libpq')
    { ... }

sub PQconnectdb( Str $conninfo )
    returns OpaquePointer
    is native('libpq')
    { ... }

sub PQerrorMessage( OpaquePointer $conn )
    returns Str
    is native('libpq')
    { ... }

sub PQexec( OpaquePointer $conn, Str $command )
    returns OpaquePointer
    is native('libpq')
    { ... }

sub PQfinish( OpaquePointer $conn )
    is native('libpq')
    { ... }

sub PQfname( OpaquePointer $res, Int $fieldnum )
    returns Str
    is native('libpq')
    { ... }

sub PQgetvalue( OpaquePointer $res, Int $tuplenum, Int $fieldnum )
    returns Str
    is native('libpq')
    { ... }

sub PQnfields( OpaquePointer $res )
    returns Int
    is native('libpq')
    { ... }

sub PQntuples( OpaquePointer $res )
    returns Int
    is native('libpq')
    { ... }

sub PQresultStatus( OpaquePointer $res )
    returns Int
    is native('libpq')
    { ... }

sub PQstatus( OpaquePointer $conn )
    returns Int
    is native('libpq')
    { ... }

 # from libpq-fe.h  These should of course be constants or perhaps even enums
sub CONNECTION_OK     { 0 }
sub CONNECTION_BAD    { 1 }

sub PGRES_EMPTY_QUERY { 0 }
sub PGRES_COMMAND_OK  { 1 }
sub PGRES_TUPLES_OK   { 2 }

sub exit_nicely(OpaquePointer $conn)
{
    PQfinish($conn);
    exit(1);
}

my $conninfo;
my $conn;
my $res;
my $nFields;
my $i,
my $j;

#
#   If the user supplies a parameter on the command line, use it as the
#   conninfo string; otherwise default to setting dbname=postgres and using
#   environment variables or defaults for all other connection parameters.
#
if ( @*ARGS.elems > 0 ) {
    $conninfo = @*ARGS[0];
}
else {
    $conninfo = "host=localhost user=testuser password=testpass dbname=zavolaj";
}

# Make a connection to the database
say "connecting";
$conn = PQconnectdb($conninfo);

# Check to see that the backend connection was successfully made
if (PQstatus($conn) != CONNECTION_OK)
{
    $*ERR.say: sprintf( "Connection to database failed: %s",
            PQerrorMessage($conn));
    exit_nicely($conn);
}

#
#   Our test case here involves using a cursor, for which we must be inside
#   a transaction block.  We could do the whole thing with a single
#   PQexec() of "select * from pg_database", but that's too trivial to make
#   a good example.
#

# Start a transaction block
$res = PQexec($conn, "BEGIN");

if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("BEGIN command failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}

#
#   Should PQclear PGresult whenever it is no longer needed to avoid memory
#   leaks
#

PQclear($res);

#
# Fetch rows from pg_database, the system catalog of databases
#
$res = PQexec($conn, "DECLARE myportal CURSOR FOR select * from pg_database");
if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("DECLARE CURSOR failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}
PQclear($res);

$res = PQexec($conn, "FETCH ALL in myportal");
if (PQresultStatus($res) != PGRES_TUPLES_OK)
{
    $*ERR.say: sprintf("FETCH ALL failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}

# first, print out the attribute names
$nFields = PQnfields($res);
loop ($i = 0; $i < $nFields; $i++) {
    printf("%-15s", PQfname($res, $i));
}
printf("\n\n");


PQclear($res);

# close the portal ... we don't bother to check for errors ...
$res = PQexec($conn, "CLOSE myportal");
PQclear($res);

# end the transaction
$res = PQexec($conn, "END");
PQclear($res);

# the example 1 code is all done, now copy the mysqlclient example
say "DROP TABLE nom";
$res = PQexec($conn,"
    DROP TABLE nom
");
if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("DROP TABLE failed: %s", PQerrorMessage($conn));
}
PQclear($res);

say "CREATE TABLE nom";
$res = PQexec($conn,"
    CREATE TABLE nom (
        name char(4),
        description char(30),
        quantity int,
        price numeric(5,2)
    )
");
if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("CREATE TABLE failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}
PQclear($res);

say "INSERT nom";
$res = PQexec($conn, "
    INSERT INTO nom (name, description, quantity, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 ),
           ( 'TAFM', 'Mild fish taco',           1, 4.85 ),
           ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
");
if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("INSERT nom failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}
PQclear($res);

say "SELECT *, quantity*price AS amount FROM nom";
$res = PQexec($conn, "
    SELECT *, quantity*price AS amount FROM nom
");

print "field_count ";
my $field_count = PQnfields($res);
say $field_count;

say "Columns:";
loop ( my $column_number=0; $column_number < $field_count; $column_number++ ) {
    my $column_name = PQfname($res, $column_number);
    say "  $column_name";
}

print "row_count ";
my $row_count = PQntuples($res);
say $row_count;

# next, print out the rows
my @rows;
my @width = 0 xx $field_count;
loop ( my $row_number=0; $row_number < $row_count; $row_number++ ) {
    my @row = ();
    loop ( my $field_number = 0; $field_number < $field_count; $field_number++ ) {
        my $field = PQgetvalue($res, $row_number, $field_number);
        my $chars = $field.chars;
        if $chars > @width[$field_number] {
            @width[$field_number] = $chars;
        }
        push @row, $field;
    }
    push @rows, [@row];
}
# Having determined the column widths by measuring every field,
# it is finally possible to pretty print the table.

loop ( $j=0; $j < $field_count; $j++ ) {
    print "+--";
    print '-' x @width[$j];
}
say '+';
loop ( $i=0; $i<$row_count; $i++ ) {
    my @row = @rows[$i];
    loop ( $j=0; $j<$field_count; $j++ ) {
        my $field = @row[0][$j];
        print "| $field ";
        print ' ' x ( @width[$j] - $field.chars );
    }
    say '|';
}
loop ( $j=0; $j<$field_count; $j++ ) {
    print "+--";
    print '-' x @width[$j];
}
say '+';

say "DROP TABLE nom";
$res = PQexec($conn,"
    DROP TABLE nom
");
if (PQresultStatus($res) != PGRES_COMMAND_OK)
{
    $*ERR.say: sprintf("DROP TABLE failed: %s", PQerrorMessage($conn));
    PQclear($res);
    exit_nicely($conn);
}
PQclear($res);


# close the connection to the database and cleanup
PQfinish($conn);

=begin pod

=head1 PREREQUISITES
Your system should already have libpq-dev installed.  Change to the
postgres user and connect to the postgres server as follows:

 sudo -U postgres psql

Then set up a test environment with the following:

 CREATE DATABASE zavolaj;
 CREATE ROLE testuser LOGIN PASSWORD 'testpass';
 GRANT ALL PRIVILEGES ON DATABASE zavolaj TO testuser;

The '\l' psql command output should include zavolaj as a database name.
Exit the psql client with a ^D, then try to use the new account:

 psql --host=localhost --dbname=zavolaj --username=testuser --password
 SELECT * FROM pg_database;

=end pod
