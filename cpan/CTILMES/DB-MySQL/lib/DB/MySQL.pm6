use DB;
use DB::MySQL::Connection;
use DB::MySQL::Native;

class DB::MySQL does DB
{
    has Str $.host = 'localhost';
    has Int $.port = 3306;
    has Str $.database;
    has Str $.user;
    has Str $.password;
    has Str $.socket;
    has Int $.flags = 0;
    has Str $.default-file;
    has Str $.group = 'client';
    has Int $.connect-timeout;
    has Int $.read-timeout;
    has Int $.write-timeout;
    has Lock $.lock .= new;       # Just because I'm paranoid, should I remove?

    method connect(--> DB::MySQL::Connection)
    {
        my $conn = $!lock.protect: { DB::MySQL::Native.init }

        $conn.option(MYSQL_OPT_CONNECT_TIMEOUT, $_) with $!connect-timeout;
        $conn.option(MYSQL_OPT_READ_TIMEOUT, $_) with $!read-timeout;
        $conn.option(MYSQL_OPT_WRITE_TIMEOUT, $_) with $!write-timeout;
        $conn.option(MYSQL_READ_DEFAULT_FILE, $_) with $!default-file;
        $conn.option(MYSQL_READ_DEFAULT_GROUP, $_) with $!group;

        $conn.connect($!host, $!user, $!password, $!database, $!port,
                      $!socket, $!flags) // $conn.check;

        DB::MySQL::Connection.new(:owner(self), :$conn)
    }
}

=begin pod

=head1 NAME

DB::MySQL -- MySQL database access for Perl 6

=head1 SYNOPSIS

my $my = DB::MySQL.new;  # You can pass in connection information if you want.

say $my.query('select 42').value;
# 42

$my.execute('insert into foo (x,y) values (1,2)');

for $my.query('select * from foo').arrays -> @row {
    say @row;
}

for $my.query('select * from foo').hashes -> %row {
    say %row;
}

=head1 DESCRIPTION

The main C<DB::MySQL> object.  It manages a pool of database connections
(C<DB::MySQL::Connection>), creating new ones as needed and caching idle
ones.

It has some methods that simply allocate a database connection, call the
same method on that connection, then immediately return the connection to
the pool.

=head1 METHODS

=head2 B<new>(:$host, :$port, :$database, :$user, :$password, :$socket, :$flags,
:$default-file, :$group, :$connect-timeout, :$read-timeout, :$write-timeout)

=head2 B<db>()

Allocate a C<DB::MySQL::Connection> object, either using a cached one from the 
pool of idle connections, or creating a new one.

=head2 B<query>(Str:D $sql, Bool :$finish, Bool :$nocache)

Allocates a database connection and perform the query, then return the connection
to the pool.  B<:finish> causes the connection to return to the pool after use,
B<:nocache> causes the prepared statement not to be cached for later use.

If the query returns results, returns a C<DB::MySQL::Result> object with the 
result.

=head2 B<execute>(Str:D $sql, Bool :$finish, Bool :$store)

Allocates a database connection, executes the SQL statement, then returns the 
connection to the pool.  B<:finish> causes the connection to return to the pool
after use, B<:store> (defaults to C<True>) causes the results to be retrieved
from server to client at once instead of retrieved row by row.

If results are returned (e.g. a 'SELECT'), returns a C<DB::MySQL::Result>
(actually a C<DB::MySQL::NonStatementResult> because it is not prepared) with the
result, otherwise (e.g. 'INSERT', 'UPDATE', etc.) returns the number of affected rows.

=head2 B<finish>()

Destroys all the pooled connections and the object itself.

=end pod
