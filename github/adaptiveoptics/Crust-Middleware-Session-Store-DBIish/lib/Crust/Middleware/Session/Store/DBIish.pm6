use v6;
use Crust::Middleware::Session;
use JSON::Fast;

class Crust::Middleware::Session::Store::DBIish does Crust::Middleware::Session::StoreRole
{
    has $.dbh is required;

    has $.table         = 'sessions';
    has $.sessid-column = 'id';

    method get($cookie-name) {
	my $sth = $.dbh.prepare("SELECT session_data FROM $.table WHERE {$.sessid-column} = ?");
	$sth.execute($cookie-name);
	my @row = $sth.row;
	return @row.elems ?? from-json(@row[0]) !! ();
    }

    method set($cookie-name, $session) {
	my $sth = $.dbh.prepare("SELECT 1 FROM $.table WHERE {$.sessid-column} = ?");
	$sth.execute($cookie-name);
	
	if ($sth.row.elems) {
	    $sth = $.dbh.prepare("UPDATE $.table SET session_data = ? WHERE {$.sessid-column} = ?");
	    $sth.execute(to-json($session), $cookie-name);
	} else {
	    $sth = $.dbh.prepare("INSERT INTO $.table ({$.sessid-column}, session_data) VALUES (?, ?)");
	    $sth.execute($cookie-name, to-json($session));
	}
    }

    method remove($cookie-name) {
	my $sth = $.dbh.prepare("DELETE from $.table WHERE {$.sessid-column} = ?");
	$sth.execute($cookie-name);
    }
}
#|{
=begin pod

=TITLE class Crust::Middleware::Session::Store::DBIish

=SUBTITLE Implements database storage role for Crust::Middleware::Session

=head1 SYNOPSIS

    =begin code :skip-test
    use Crust::Builder;
    use Crust::Middleware::Session;
    use Crust::Middleware::Session::Store::DBIish;

    sub app($env) {
	$env<p6sgix.session>.get('username').say if $env<p6sgix.session>.defined;
	$env<p6sgix.session>.set('username', 'ima-username');

	# ...crust-y stuff...
    }

    my $store   = Crust::Middleware::Session::Store::DBIish.new(:dbh($dbh));
    my $builder = Crust::Builder.new;
    
    $builder.add-middleware('Session', store => $store);
    $builder.wrap(&app);
    =end code

=head1 DESCRIPTION
    
Crust::Middleware::Session::Store::DBIish implements a backend storage
role for Crust::Middleware::Session in any database supported by
DBIish.

You must pass in a database handle to new().

Session data is stored serialized in the database table as JSON and is
de-serialized from JSON on get, and made available via the normal
Crust::Middleware::Session methods.

The very fast and compact JSON::Fast is used to serialize and
de-serialize the session data to the database table.

=head1 ATTRIBUTES

=head2 dbh

An active DBIish database handle to the database where session data
will be stored.

=head2 table

Table name that will store session data (defaults to "sessions").

=head2 sessid-column

By default the "id" database column is used for cookie session id
searches and updates. You can change the column name used to identify
session ids with sessid-column in case your 'id' column is used for
something else.

=head1 DATABASE

The database table is called "sessions" by default. This table needs
at least 2 columns, named "id" and "session_data".

The C<id> column is the SHA key used as sessions identifiers by
Crust::Middleware::Sessions, and the C<session_data> column should
be big enough to hold as much session data as you think you might
need.

The one I just created for sessions was done as follows, and includes
a column of "created" which contains the time that particular session
was created (for later database purging).

    =begin code :skip-test
    $dbh.do(qq:to/SQL/);
    CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        session_data text,
        created timestamp with time zone not null default now()
    )
    SQL
    =end code

You probably should probably make your "id" column unique, as happens
with Postgresql's PRIMARY KEY attribute.

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
}
