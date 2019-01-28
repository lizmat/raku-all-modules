use DB::Statement;

role DB::Connection
{
    has $.owner is required;
    has Bool $!transaction = False;
    has %!prepare-cache;

    method ping(--> Bool) { True }

    method free(--> Nil) {}

    method prepare-nocache(Str:D $query --> DB::Statement) {...}

    # execute defaults to the same as query(), but some modules
    # do different things with it.
    method execute(Str:D $command, Bool :$finish, |args)
    {
        $.prepare($command).execute(|args, :$finish);
    }

    method clear-cache(--> Nil)
    {
        .free for %!prepare-cache.values;
        %!prepare-cache = ()
    }

    method finish(--> Nil)
    {
        if $.ping
        {
            $.rollback if $!transaction;
            $!owner.cache(self);
        }
        else
        {
            self.DESTROY
        }
    }

    method prepare(Str:D $query, Bool :$nocache --> DB::Statement)
    {
        return $.prepare-nocache($query) if $nocache;
        return $_ with %!prepare-cache{$query};
        %!prepare-cache{$query} = $.prepare-nocache($query)
    }

    method query(Str:D $query, Bool :$finish, Bool :$nocache, |args)
    {
        $.prepare($query, :$nocache).execute(|args, :$finish);
    }

    method begin(--> DB::Connection)
    {
        self.execute('begin');
        $!transaction = True;
        self
    }

    method commit(--> DB::Connection)
    {
        self.execute('commit');
        $!transaction = False;
        self
    }

    method rollback(--> DB::Connection)
    {
        self.execute('rollback');
        $!transaction = False;
        self
    }

    submethod DESTROY()
    {
        self.clear-cache;
        self.free
    }
}
