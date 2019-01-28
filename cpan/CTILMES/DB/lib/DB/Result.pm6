class DB::Result::ArrayIterator does Iterator
{
    has $.result is required;

    method pull-one()
    {
        $!result.row or do
        {
            $!result.finish;
            IterationEnd
        }
    }
}

class DB::Result::HashIterator does Iterator
{
    has $.result is required;

    method pull-one()
    {
        my $row = $!result.row or do
        {
            $!result.finish;
            return IterationEnd
        }
        %( $!result.keys.list Z=> @$row )
    }
}

role DB::Result
{
    has $.sth;
    has Bool $.finish;

    method free() {}

    method finish(--> Nil)
    {
        self.free;
        $!sth.finish if $!finish && $!sth;
    }

    method row() { ... }

    method names() { ... }

    method keys()
    {
        state $keys;
        $keys // ($keys = $.names)
    }

    method value()
    {
        LEAVE $.finish;
        $.row[0]
    }

    method array()
    {
        LEAVE $.finish;
        $.row
    }

    method hash()
    {
        LEAVE $.finish;
        %( @$.keys Z=> @$.row )
    }

    method arrays()
    {
        Seq.new: DB::Result::ArrayIterator.new(result => self)
    }

    method hashes()
    {
        Seq.new: DB::Result::HashIterator.new(result => self)
    }

    submethod DESTROY()
    {
        self.free
    }
}
