use DB::Connection;
use DB::MySQL::Native;
use DB::MySQL::Statement;

class DB::MySQL::Connection does DB::Connection
{
    has DB::MySQL::Native $.conn is required
        handles <client-version client-info host-info server-info
                 server-version proto-info ssl-cipher select-db stat
                 info check insert-id>;

    method ping(--> Bool) { $!conn && $!conn.ping == 0 }

    method free(--> Nil)
    {
        .close with $!conn;
        $!conn = Nil;
    }

    method prepare-nocache(Str:D $query --> DB::MySQL::Statement)
    {
        my $stmt = $!conn.stmt-init // $!conn.check;

        my $buf = $query.encode;
        $stmt.prepare($buf, $buf.bytes) || $stmt.check;

        DB::MySQL::Statement.new(:db(self), :$stmt)
    }

    method execute(Str:D $command, Bool :$finish, Bool :$store = True)
    {
        $!conn.query($command) && $!conn.check;

        my $result = ($store ?? $!conn.store-result !! $!conn.use-result)
            // return $!conn.check.affected-rows;

        DB::MySQL::NonStatementResult.new(:db(self), :$result, :$finish);
    }
}

=begin pod

=head1 NAME

DB::MySQL::Connection -- Database connection object

=head1 SYNOPSIS

my $my = DB::MySQL.new;

my $db = $my.db;

say "Good connection" if $db.ping;

say $db.query('select * from foo where x = ?', 27).hash;

my $sth = $db.prepare('select * from foo where x = ?'); # DB::MySQL::Statement

$db.execute('insert into foo (x,y) values (1,2)'); # No placeholder args

$db.begin;
$db.commit;
$db.rollback;

$db.finish; # Finished with database connection, return to idle pool

=head1 DESCRIPTION

Always allocate from a C<DB::MySQL> object with the C<.db> method.  Use
C<.finish> to return the database connection to the pool when finished.

=head1 METHODS

=head2 B<finish>()

Return this database connection to the connection pool in the parent C<DB::MySQL>
object.

=head2 B<ping>()

Returns C<True> if the connection to the server is active.

=head2 B<execute>(Str:D $sql, Bool :$finish, Bool :$store)

Executes the sql statement.  C<:finish> causes the database connection to
be C<finish>ed after the command executes.  C<:store> (defaults to C<True>)
causes the results to be retrieved from server to client at once instead of
retrieved row by row.

If results are returned (e.g. a 'SELECT'), returns a C<DB::MySQL::Result>
(actually a C<DB::MySQL::NonStatementResult> because it is not prepared) with the
result, otherwise (e.g. 'INSERT', 'UPDATE', etc.) returns the number of affected rows.

=head2 B<prepare>(Str:D $query, Bool :$nocache --> DB::MySQL::Statement)

Prepares the SQL query, returning a C<DB::MySQL::Statement> object with the prepared
query.  These are cached in the database connection object, so if the same query
is prepared again, the previous statement is returned.  You can avoid the statement
caching by setting C<:nocache> to C<True> (or by calling B<prepare-nocache>()).

=head2 B<prepare-nocache>(Str:D $query --> DB::MySQL::Statement)

Prepares the SQL query, returning a C<DB::MySQL::Statement> object with the prepared
query.

=head2 B<query>(Str:D $query, Bool :$finish, Bool :$nocache, *@args)

prepares, then executes the query with the supplied arguments.

=head2 B<begin>()

Begins a new database transaction.  Returns the C<DB::MySQL::Connection> object.

=head2 B<commit>()

Commits an active database transaction.  Returns the C<DB::MySQL::Connection> object.

=head2 B<rollback>()

Rolls back an active database transaction.  If the database is
finished with an active transaction, it will be rolled back
automatically.  Returns the C<DB::MySQL::Connection> object.

=end pod
