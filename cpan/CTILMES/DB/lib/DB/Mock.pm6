use DB;
use DB::Connection;
use DB::Statement;
use DB::Result;

our $mock-connections = 0;
our $mock-statements = 0;
our $mock-results = 0;

class DB::Mock::Result does DB::Result
{
    has $.alive = True;
    has $.r = 0;
    has $.max;

    method free() { $mock-results--  if $!alive; $!alive = False }

    method names() { <a b c> }

    method row()
    {
        (++$!r > $!max) ?? () !! ($!r<>, "string {$!r}", Any)
    }
}

class DB::Mock::Statement does DB::Statement
{
    has $.alive = True;
    method free() { $mock-statements-- if $!alive; $!alive = False }

    method execute(Bool :$finish, *@args)
    {
        $mock-results++;
        DB::Mock::Result.new(:sth(self), :$finish, max => @args[0] // 5)
    }
}

class DB::Mock::Connection does DB::Connection
{
    has $.alive = True;
    has $.state is rw = True;

    method ping(--> Bool) { $!state }

    method free(--> Nil) { $mock-connections-- if $!alive; $!alive = False }

    method prepare-nocache(Str:D $query --> DB::Mock::Statement)
    {
        $mock-statements++;
        DB::Mock::Statement.new(:db(self))
    }

    method execute(Str:D $query, Bool :$finish)
    {
        LEAVE $.finish if $finish;
        return 1;
    }
}

class DB::Mock does DB
{
    method connect(--> DB::Mock::Connection)
    {
        $mock-connections++;
        DB::Mock::Connection.new(:owner(self))
    }
}
