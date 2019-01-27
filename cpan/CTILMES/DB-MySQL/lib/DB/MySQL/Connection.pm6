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
