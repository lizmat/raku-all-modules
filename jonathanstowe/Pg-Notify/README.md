# PG::Notify

Perl6-ish interface to PostgresQL notifies.

## Synopsis

```perl6


use Pg::Notify;
use DBIish;

my $db = DBIish.connect('Pg', database => "dbdishtest");
my $channel = "test";

my $notify = Pg::Notify.new(:$db, :$channel );

react {
    whenever $notify -> $notification {
        say $notification.extra;
    }
	# Provide a notification
	whenever Supply.interval(1) -> $v {
		$db.do("NOTIFY $channel, '$v'");
	}
}
```

## Description

This provides a simple mechanism to get a supply of the PostgresQL notifications
for a particular *channel*.  The supply will emit a stream of ```pg-notify``` objects
corresponding to a ```NOTIFY``` executed on the connected Postgres database.

Typically the ```NOTIFY``` will be invoked in a trigger or other server side code
but could just as easily be in some other user code (as in the Synopsis above,)

The objects of type ```Pg::Notify``` have a ```Supply``` method that allows coercion
in places that expect a Supply (such as ```whenever``` in the Synopsis above.) but
you can this Supply directly if you want to ```tap``` it for instance.

## Install

This relies on [DBIish](https://github.com/perl6/DBIish) and ideally you will have
a working PostgreSQL database connection for the user that you will run the tests as.

For the tests you can control how it connects to the database with the environment variables:

*  $PG_NOTIFY_DB   - the name of the database you want to use, otherwise ```dbdishtest```
*  $PG_NOTIFY_USER - the username to be used, (otherwise will connect as the current user,)
*  $PG_NOTIFY_PASS - the password to be used, (otherwise no password will be used.)

These should be set before the tests (or install,) are run.

Assuming you have a working Rakudo Perl 6 installation you should just be able to use *zef* :

	zef install Pg::Notify

	# or from a local copy

	zef install .

Or indeed *panda* :

	panda install Pg::Notify

	# or from a local copy

	panda install .

But I can't think there should be any problem with any installer that may come along in the future.

## Support

This relies on the ```poll``` C library function, on Linux this is part of the runtime library that
is always loaded but it might not be on other operating systems, if you have one of those systems
I'd be grateful for a patch to make it work there.

If you have any other suggestions or problems please report at https://github.com/jonathanstowe/Pg-Notify/issues

## Copyright and Licence

This is free software, please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2017

