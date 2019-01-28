role DB::Statement
{
    has $.db is required;

    method free(--> Nil) {}

    method execute() {...}

    method finish(--> Nil)
    {
        $!db.finish
    }

    submethod DESTROY() { self.free }
}
