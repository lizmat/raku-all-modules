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
                                                $!result-bind[$i])
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
