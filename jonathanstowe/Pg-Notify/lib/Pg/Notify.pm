use v6.c;

use NativeCall;
use NativeHelpers::CStruct;
need DBDish::Pg::Connection;

=begin pod

=head1 NAME

Pg::Notify - Reactive interface to PostgreSQL notifications

=head1 SYNOPSIS

=begin code

use Pg::Notify;
use DBIish;

my $db = DBIish.connect('Pg', database => "dbdishtest");
my $channel = "test";

my $notify = Pg::Notify.new(:$db, :$channel );

react {
    whenever $notify -> $notification {
        say $notification.extra;
    }
    whenever Supply.interval(1) -> $v {
        say $db.do("NOTIFY $channel, '$v'");
    }
}

=end code

=head1 DESCRIPTION

This provides a simple mechanism to get a supply of the PostgresQL
notifications for a particular channel. The supply will emit a stream
of pg-notify objects corresponding to a NOTIFY executed on the connected
Postgres database.

Typically the NOTIFY will be invoked in a trigger or other server side
code but could just as easily be in some other user code (as in the
Synopsis above,)

The objects of type Pg::Notify have a Supply method that allows coercion
in places that expect a Supply (such as whenever in the Synopsis
above.) but you can this Supply directly if you want to tap it for
instance.

=head1 METHODS

=head2 method new

    method new(DBDish::Pg::Connection :$db, Str :$channel)

Both parameters are required. C<$db> should be the result of a
C<DBIish.connect> to a Postgres database,  C<$channel> should be
the name of the NOTIFY topic that you want to receive.  If you
want to receive notifications for another topic you should
create another Pg::Notify.

=head2 method Supply

    method Supply() returns Supply

This returns the Supply onto which the notifications are emitted as
they arrive, it will act as a coercer in certain places such as a
C<whenever> which expect a Supply.

The objects emitted are C<DBDish::Pg::Native::pg-notify> with the
following members:

=head3 relname

The name of the "topic" or "channel" the notification is for.

=head3 be_pid

The Process ID of the process in which the NOTIFY was executed.

=head3 extra

The string "payload" of the notification, it is optional on the
NOTIFY command so may be undefined.  There is a limit of about
8192 Bytes on the size of the oayload. The encoding of the payload
is a function of the server configuration.

=head2 method unlisten()

    method unlisten()

This will call UNLISTEN on the database connection and terminate
the thread that polls for new notifications, after calling this
if you want to resume listening for notifications you will need
to create a new object.

=end pod

class Pg::Notify {
    has DBDish::Pg::Connection  $.db      is required;
    has Str                     $.channel is required;

    has $!thread;

    has Supplier $!supplier;

    has Promise $!run-promise;

    class PollFD is repr('CStruct') {
        has int32 $.fd;
        has int16 $.events;
        has int16 $.revents;
    }

    sub poll(PollFD $fds, int64 $nfds, int32 $timeout) returns int32 is native { * }

    method supplier() returns Supplier handles <Supply> {
        $!supplier //= do {
            my $supplier = Supplier.new;
            self.listen;
            $!run-promise = Promise.new;
            $!thread = Thread.start: :app_lifetime, {
                loop {
                    #last if $!run-promise.status ~~ Kept;
                    $!db.pg-consume-input;
                    if $!db.pg-notifies -> $not {
                        if $not.relname eq $!channel {
                            $supplier.emit: $not;
                        }
                    }
					self.poll-once;
                }
            }
            $supplier;
        }
    }

    method poll-once() returns Int {
        my $fds = LinearArray[PollFD].new(1);
        $fds[0] = PollFD.new(fd => $!db.pg-socket,  events => 1, revents => 0);
        poll($fds.base, 1, -1);
        my $rc = $fds[0].revents;
        $fds.dispose;
        $rc;
    }


    method listen() {
        $!db.do("LISTEN " ~ $!channel);
    }

    method unlisten() {
        $!db.do("UNLISTEN " ~ $!channel);
        if $!run-promise {
            $!run-promise.keep: True;
        }
    }
}


# vim: ft=perl6 ts=4 sw=4 expandtab
