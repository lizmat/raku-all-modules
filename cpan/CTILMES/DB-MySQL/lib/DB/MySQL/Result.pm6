use DB::MySQL::Converter;
use DB::MySQL::Native;
use DB::Result;

role DB::MySQL::Result does DB::Result
{
    has MYSQL_RES $.result is required;
    has $.num-fields = $!result.num-fields;
    has $.fields = $!result.fetch-fields;

    method names() { do for ^$!num-fields { $!fields[$_].name } }
}

class DB::MySQL::NonStatementResult does DB::MySQL::Result
{
    has $.db is required;

    method finish() { $.free; .finish with $!db }  # free db instead of sth

    method free()
    {
        .free with $!result;
        $!result = Nil
    }

    method row()
    {
        my $row = $!result.fetch-row // return ();
        my $lengths = $!result.fetch-lengths;

        do for ^$!num-fields -> $i
        {
            my $val = DB::MySQL::Converter.value(
                $!fields[$i].type, $row[$i], $lengths[$i]);
        }
    }
}

class DB::MySQL::StatementResult does DB::MySQL::Result
{
    has MYSQL_STMT $.stmt is required;
    has DB::MySQL::Native::ResultsBind $.result-bind;

    method free()
    {
        while $.row {}                           # Exhaust unread results
        .free with $!result-bind;
        .free with $!result;
        $!result-bind = Nil;
        $!result = Nil;
    }

    submethod TWEAK()
    {
        $!result-bind = DB::MySQL::Native::ResultsBind.new(:count($!num-fields));

        for ^$!num-fields -> $i
        {
            DB::MySQL::Converter.make-buffer($!result-bind[$i], $!fields[$i])
        }

        $!stmt.check if $!stmt.bind-result($!result-bind[0]);
    }

    method row(Bool :$hash)
    {
        if (my $res = $!stmt.fetch) == 0
        {
            do for ^$!num-fields -> $i
            {
                DB::MySQL::Converter.bind-value($!fields[$i].type,
                                                $!result-bind[$i],
                                                null => ?$!result-bind.nulls[$i])
            }
        }
        else
        {
            given $res
            {
                when 1 { $!stmt.check }
                when MYSQL_NO_DATA { return () }
                when MYSQL_DATA_TRUNCATED { die "truncated" }
            }
        }
    }
}

=begin pod

=head1 NAME

DB::MySQL::Result -- Results from a MySQL query

=head1 SYNOPSIS

my $results = $sth.execute(1);

say $results.num-fields; # Number of column fields
say $results.keys;       # Array of column field keys

say $results.value;      # A single scalar value

say $results.array;      # A single array with one row

say $results.hash;       # A single hash with one row

say $results.arrays;     # A sequence of arrays with all rows

say $results.hashes;     # A sequence of hashes with all rows

$results.finish;         # Only needed if results aren't consumed.

=head1 DESCRIPTION

Returned from a C<DB::MySQL::Statement> execution that returns
results.  There are two flavors, C<DB::MySQL::StatementResult>
returned from a prepared statement, and
C<DB::MySQL::NonStatementResult> returned from an B<execute>(),
but they act the same.

If the execute was passed the C<:store> flag (normally C<True> by
default), the results are all retrieved from the server at once,
then doled out as requested.  If C<:store> is set to C<False>,
each row is retrieved from the server on request.  This can tie
up server resources so results should be consumed quickly.  Read
the MySQL documentation for more details on the distinction.

=head1 METHODS

=head2 B<num-fields>()

Returns the number of fields in each row.

=head2 B<keys>()

Array of the names of the columns (fields) to be returned.

=head2 B<finish>()

Finish the database connection.  This is only needed if the complete
database returns aren't consumed.

=head2 B<value>()

Return a single scalar value from the results.

=head2 B<array>()

Return a single row from the results as an array.

=head2 B<hash>()

Return a single row from the results as a hash.

=head2 B<arrays>()

Return a sequence of all rows as arrays.

=head2 B<hashes>()

Return a sequence of all rows as hashes.

=end pod
