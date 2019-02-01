use DB::Statement;
use DB::MySQL::Native;
use DB::MySQL::Result;
use DB::MySQL::Converter;

class DB::MySQL::Statement does DB::Statement
{
    has MYSQL_STMT $.stmt is required;
    has Int $.param-count;
    has DB::MySQL::Native::ParamsBind $.params;

    submethod BUILD(:$!db, :$!stmt)
    {
        if ($!param-count = $!stmt.param-count) > 0
        {
            $!params = DB::MySQL::Native::ParamsBind.new(:count($!param-count))
        }
    }

    method free(--> Nil)
    {
        .free with $!params;
        $!params = Nil;
        .close with $!stmt;
        $!stmt = Nil;
    }

    method execute(**@args, Bool :$finish, Bool :$store = True)
    {
        die DB::MySQL::Error.new(message => 'Wrong number of params')
            unless @args.elems == $!param-count;

        if $!param-count
        {
            $!params.bind-params(@args);
            $!stmt.check($!stmt.bind-param($!params[0]))
        }

        $!stmt.check if $!stmt.execute || ($store && $!stmt.store-result);

        if my $result = $!stmt.result-metadata
        {
            return DB::MySQL::StatementResult.new(sth => self, :$!stmt,
                                                  :$result, :$finish)
        }

        my $ret = return $!stmt.affected-rows;
        $!db.finish if $finish;
        return $ret;
    }
}

=begin pod

=head1 NAME

DB::MySQL::Statement -- MySQL prepared statement object

=head1 SYNOPSIS

my $my = DB::MySQL.new;

my $db = $my.db;

my $sth = $db.prepare('select * from foo where x = ?');

my $result = $sth.execute(12);

=head1 DESCRIPTION

Holds a prepared database statement.  The only thing you can
really do with a prepared statement is to C<execute> it with 
arguments to bind to the prepared placeholders.

=head1 METHODS

=head2 B<execute>(**@args, Bool :$finish, Bool :$store = True)

Executes the database statement with the supplied arguments.

If the database returns results (e.g. for a 'SELECT'), this returns
a C<DB::MySQL::Result> (actually a C<DB::MySQL::StatementResult>)
object.

If C<:finish> is C<True> the database connection will C<finish>
following the execution and retrieval of the results.

If the database does not return results (e.g. an 'INSERT'), it
will return the number of rows affected by the query.

B<:store> (defaults to C<True>) causes the results to be retrieved
from server to client at once instead of retrieved row by row.

=head2 B<finish>()

Calls C<finish> on the creating database connection.

=head2 B<free>()

Frees the resources associated with the prepared statement.  You
normally do not need to call this since cached statements want to
stick around, and it will automatically be called when the garbage
collector reaps the object anyway.

=end pod
