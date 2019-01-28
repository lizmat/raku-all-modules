use Concurrent::Stack;
use DB::Connection;

role DB
{
    has $.max-connections = 5;
    has $.connections = Concurrent::Stack.new;

    method connect(--> DB::Connection) {...}

    method db(--> DB::Connection)
    {
        while my $db = $!connections.pop
        {
            return $db if $db.ping;
            $db.DESTROY
        }
        $.connect
    }

    method query(|args)
    {
        $.db.query(:finish, |args)
    }

    method execute(|args)
    {
        $.db.execute(:finish, |args)
    }

    method cache(DB::Connection:D $db)
    {
        if $!connections.elems < $!max-connections
        {
            $!connections.push($db)
        }
        else
        {
            $db.DESTROY
        }
    }

    method finish(--> Nil)
    {
        while $_ = $!connections.pop
        {
            .DESTROY;
        }
    }

    submethod DESTROY()
    {
        self.finish
    }
}
