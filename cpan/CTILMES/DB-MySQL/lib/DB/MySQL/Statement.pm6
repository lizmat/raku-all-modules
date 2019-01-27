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
