# mysqlclient.p6

# Requirements:
# 1. MySQL client lib (eg on Debian, sudo apt-get install mysqlclient-dev
# 2. An account and a database on a MySQL server, for this example:
#    username = testuser
#    password = testpass
#    database = zavolaj
# 3. Permissions, eg "grant all privileges on zavolaj.* to testuser@localhost"

# Fortunately made possible by explicitly by hardcoded support in
# parrot/src/nci/extra_thunks.nci.
# See /usr/include/mysql.h for what should be callable, or browse
# http://dev.mysql.com/doc/refman/5.1/en/c-api-function-overview.html

# Status:
# Works: affected_rows close connect error fetch_field fetch_row
#        field_count free_result get_client_info init num_rows query
#        real_connect stat store_result use_result
# Fails: create_db library_end library_init
# The reason for most failures is that a mapping is not available
# between the native data types and the Perl 6 data types that must be
# used in the foreign function definitions below.
# As NativeCall.pm, Rakudo and Parrot continue to evolve, more of the
# functions that have not worked may become usable.
# Volunteers, please test from time to time and give feedback in #perl6.

use NativeCall;

# -------- foreign function definitions in alphabetical order ----------

sub mysql_affected_rows( OpaquePointer $mysql_client )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_close( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_data_seek( OpaquePointer $result_set, Int $row_number )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_error( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_field( OpaquePointer $result_set )
    returns Positional of Str
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_lengths( OpaquePointer $result_set )
    returns Positional of Int
    is native('libmysqlclient')
    { ... }

sub mysql_fetch_row( OpaquePointer $result_set )
    returns Positional of Str
    is native('libmysqlclient')
    { ... }

sub mysql_field_count( OpaquePointer $mysql_client )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_free_result( OpaquePointer $result_set )
#   returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_get_client_info( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_init( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_library_init( Int $argc, OpaquePointer $argv,
    OpaquePointer $group )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_library_end()
#   returns OpaquePointer # currently not working, should be void
    is native('libmysqlclient')
    { ... }

sub mysql_num_rows( OpaquePointer $result_set )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_query( OpaquePointer $mysql_client, Str $sql_command )
    returns Int
    is native('libmysqlclient')
    { ... }

sub mysql_real_connect( OpaquePointer $mysql_client, Str $host, Str $user,
    Str $password, Str $database, Int $port, Str $socket, Int $flag )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_stat( OpaquePointer $mysql_client)
    returns Str
    is native('libmysqlclient')
    { ... }

sub mysql_store_result( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

sub mysql_use_result( OpaquePointer $mysql_client )
    returns OpaquePointer
    is native('libmysqlclient')
    { ... }

# ----------------------- main example program -------------------------

# Structure as recommended in the MySQL 5.1 Reference Manual, C API.
# Follow the 5 step general outline after the function summary in
# http://dev.mysql.com/doc/refman/5.1/en/c-api-function-overview.html

# strictly necessary only in multithreaded programs
print "library_init [currently not working] ";
#my $library_init_result = mysql_library_init( 0, pir::null__P(),
#    pir::null__P() );
#if $library_init_result != 0 {
#    die "could not initialize MySQL library, returned $library_init_result";
#}
say "";

say "init";
my $client = mysql_init( pir::null__P() );
print mysql_error($client);

print "get_client_info: ";
say mysql_get_client_info($client);

say "real_connect";
mysql_real_connect( $client, 'localhost', 'testuser', 'testpass',
    'mysql', 0, pir::null__P(), 0 );
print mysql_error($client);

print "stat: ";
say mysql_stat($client);

say "DROP DATABASE zavolaj";
mysql_query( $client, "
    DROP DATABASE zavolaj
");
print mysql_error($client);

say "CREATE DATABASE zavolaj";
mysql_query( $client, "
    CREATE DATABASE zavolaj
");
print mysql_error($client);

say "USE zavolaj";
mysql_query( $client, "
    USE zavolaj
");
print mysql_error($client);

say "CREATE TABLE nom";
mysql_query( $client,"
    CREATE TABLE nom (
        name char(4),
        description char(30),
        quantity int,
        price numeric(5,2)
    )
");
print mysql_error($client);

say "INSERT nom";
mysql_query( $client, "
    INSERT nom (name, description, quantity, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 ),
           ( 'TAFM', 'Mild fish taco',           1, 4.85 ),
           ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
");
print mysql_error($client);

print "affected rows ";
my $affected_rows = mysql_affected_rows( $client );
print mysql_error($client);
say $affected_rows;

say "SELECT *, quantity*price AS amount FROM nom";
mysql_query( $client, "
    SELECT *, quantity*price AS amount FROM nom
");
print mysql_error($client);

print "field_count ";
my $field_count = mysql_field_count($client);
print mysql_error($client);
say $field_count;

my @rows;
my $row_count;
my @width = 0 xx $field_count;
# There are two ways to retrieve result sets: all at once in a single
# batch, or one row at a time.  Choose according to the amount of data
# and the overhead on the server and the client.
my $batch-mode;
$batch-mode = (True,False).pick; # aha, you came looking for this line :-)
#$batch-mode = False;
if $batch-mode {
    # Retrieve all the rows in a single batch operation
    say "store_result";
    my $result_set = mysql_store_result($client);
    print mysql_error($client);

    say "Columns:";
    loop ( my $column_number=0; $column_number<$field_count; $column_number++ ) {
        my $field_info = mysql_fetch_field($result_set);
        my $column_name = $field_info[0];
        say "  $column_name";
    }

    print "row_count ";
    $row_count = mysql_num_rows($result_set);
    print mysql_error($client);
    say $row_count;

    # Since mysql_fetch_fields() is not usable yet, derive the
    # column widths from the maximum widths of the data in each
    # column.
    say "fetch_row, fetch_lengths and fetch_field";
    loop ( my $row_number=0; $row_number<$row_count; $row_number++ ) {
        my $row_data = mysql_fetch_row( $result_set );
        my $field_length_array = mysql_fetch_lengths( $result_set );

        # It would be better to be able to call mysql_fetch_fields().
        # my @row = mysql_fetch_fields($result_set);
        # But that cannot be implmented yet in Rakudo because the
        # returned result is a packed binary record of character
        # pointers, unsigned longs and unsigned ints. See mysql.h
        my @row = ();
        loop ( my $field_number=0; $field_number<$field_count; $field_number++ ) {
            my $field = $row_data[$field_number];
# array of unsigned long segfaults
#           my $chars = $field_length_array[$field_number];
            my $chars = $field.chars;
            @width[$field_number] = max @width[$field_number], $chars;
            push @row, $field;
        }
        push @rows, [@row];
    }
    say "free_result";
    mysql_free_result($result_set);
    print mysql_error($client);
    # Having determined the column widths by measuring every field,
    # it is finally possible to pretty print the table.
    loop ( my $j=0; $j<$field_count; $j++ ) {
        print "+--";
        print '-' x @width[$j];
    }
    say '+';
    loop ( my $i=0; $i<$row_count; $i++ ) {
        my @row = @rows[$i];
        loop ( my $j=0; $j<$field_count; $j++ ) {
            my $field = @row[0][$j];
            print "| $field ";
            print ' ' x ( @width[$j] - $field.chars );
        }
        say '|';
    }
    loop ( my $k=0; $k<$field_count; $k++ ) {
        print "+--";
        print '-' x @width[$k];
    }
    say '+';
}
else {
    # Retrieve rows one at a time from the server
    say "use_result";
    my $result_set = mysql_use_result($client);
    print mysql_error($client);

    say "Columns:";
    loop ( my $column_number=0; $column_number<$field_count; $column_number++ ) {
        my $field_info = mysql_fetch_field($result_set);
        my $column_name = $field_info[0];
        say "  $column_name";
    }

    while my $row_data = mysql_fetch_row($result_set) {
        my @row;
        loop ( my $field_number=0; $field_number<$field_count; $field_number++ ) {
            my $field = $row_data[$field_number];
            @width[$field_number] = max @width[$field_number], $field.chars;
            push @row, $field;
        }
        @row.join(', ').say;
        # no fancy boxes this time because the width of later fields is unknown
    }
    say "free_result";
    mysql_free_result($result_set);
    print mysql_error($client);
}

say "close";
mysql_close($client);
print mysql_error($client);

say "library_end [currently not working]";
#mysql_library_end();

say "mysqlclient.p6 done";
