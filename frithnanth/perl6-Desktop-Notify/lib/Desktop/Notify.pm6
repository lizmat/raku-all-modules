#!/usr/bin/env perl6

unit class Desktop::Notify:ver<0.2.0>;

use NativeCall;

constant LIB = %*ENV<PERL6_NOTIFY_LIB> || 'libnotify.so.4';

class NotifyNotification is repr('CPointer') { * } # libnotify private struct
class GError is repr('CStruct') {
  has int64 $.domain;
  has int32 $.code;
  has Str   $.message;
}
class GList is repr('CStruct') {
  has Pointer[void] $.data;
  has GList $.next;
  has GList $.prev;
}

# Raw interface to libnotify
sub notify_init(Str $appname --> int64) is native(LIB) { * }
sub notify_uninit() is native(LIB) { * }
sub notify_is_initted(--> int64) is native(LIB) { * }
sub notify_get_app_name(--> Str) is native(LIB) { * }
sub notify_set_app_name(Str $appname) is native(LIB) { * }
sub notify_notification_new(Str $summary,
                            Str $body,
                            Str $icon --> NotifyNotification)
                            is native(LIB) { * }
sub notify_notification_show(NotifyNotification $notification, GError $error is rw --> int64)
                            is native(LIB) { * }
sub notify_notification_close(NotifyNotification $notification, GError $error is rw --> int64)
                            is native(LIB) { * }
sub notify_notification_get_closed_reason(NotifyNotification $notification --> int64)
                            is native(LIB) { * }
sub notify_notification_get_type(--> uint64) is native(LIB) { * }
sub notify_notification_update(NotifyNotification $notification,
                            Str $summary,
                            Str $body,
                            Str $icon --> int64)
                            is native(LIB) { * }
sub notify_notification_set_timeout(NotifyNotification $notification, int64 $timeout)
                            is native(LIB) { * }
sub notify_notification_set_category(NotifyNotification $notification, Str $category)
                            is native(LIB) { * }
sub notify_notification_set_urgency(NotifyNotification $notification, int64 $urgency)
                            is native(LIB) { * }
sub notify_get_server_caps(--> GList) is native(LIB) { * }
sub notify_get_server_info(Pointer[Str] $name is rw,
                           Pointer[Str] $vendor is rw,
                           Pointer[Str] $version is rw,
                           Pointer[Str] $spec_version is rw --> int64)
                           is native(LIB) { * }

# OO interface
has GError $.error is rw;
has GList $.glist is rw;
enum NotifyUrgency is export(:constants) <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>;
submethod BUILD(:$app-name!) { notify_init($app-name); $!error = GError.new };
submethod DESTROY { notify_uninit(); $!error.free };
method is-initted(--> Bool) { notify_is_initted.Bool }
multi method app-name(--> Str) { notify_get_app_name }
multi method app-name(Str $appname! --> Nil) { notify_set_app_name($appname) }
multi method new-notification(Str $summary!, Str $body!, Str $icon! --> NotifyNotification)
{
  notify_notification_new($summary, $body, $icon);
}
multi method new-notification(Str :$summary!,
                              Str :$body!,
                              Str :$icon!,
                              Int :$timeout?,
                              Str :$category?,
                              NotifyUrgency :$urgency?
                              --> NotifyNotification)
{
  my NotifyNotification $n = notify_notification_new($summary, $body, $icon);
  notify_notification_set_timeout($n, $timeout)   with $timeout ;
  notify_notification_set_category($n, $category) with $category ;
  notify_notification_set_urgency($n, $urgency)   with $urgency ;
  return $n;
}
method show(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_show($notification, $err // $!error).Bool;
}
method close(NotifyNotification $notification!, GError $err? --> Bool)
{
  notify_notification_close($notification, $err // $!error).Bool;
}
method get-type(--> Int)
{
  notify_notification_get_type();
}
method update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)
{
  notify_notification_update($notification, $summary, $body, $icon).Bool;
}
constant NOTIFY_EXPIRES_DEFAULT is export(:constants) = -1;
constant NOTIFY_EXPIRES_NEVER   is export(:constants) =  0;
method set-timeout(NotifyNotification $notification!, Int $timeout! --> Nil)
{
  notify_notification_set_timeout($notification, $timeout);
}
method set-category(NotifyNotification $notification!, Str $category! --> Nil)
{
  notify_notification_set_category($notification, $category);
}
method set-urgency(NotifyNotification $notification!, NotifyUrgency $urgency! --> Nil)
{
  notify_notification_set_urgency($notification, $urgency);
}
method why-closed(NotifyNotification $notification! --> Int)
{
  notify_notification_get_closed_reason($notification);
}
method server-caps(--> Seq)
{
  $!glist = notify_get_server_caps();
  my GList $l = self.glist;
  gather loop {
    take nativecast(Str, $l.data);
    last unless $l.next;
    $l = $l.next;
  }
}
method server-info(--> Hash)
{
  my $name = Pointer[Str].new;
  my $vendor = Pointer[Str].new;
  my $version = Pointer[Str].new;
  my $spec-version = Pointer[Str].new;
  my $ret = notify_get_server_info($name, $vendor, $version, $spec-version).Bool;
  return { return       => $ret,
           name         => nativecast(Str, $name),
           vendor       => nativecast(Str, $vendor),
           version      => Version.new(nativecast(Str, $version)),
           spec-version => Version.new(nativecast(Str, $spec-version)),
         };
}

=begin pod

=head1 NAME

Desktop::Notify - A simple interface to libnotify

=head1 SYNOPSIS
=begin code

use v6;
use Desktop::Notify :constants;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

$notify.show($n);
sleep 2;

$notify.update($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show($n);

=end code

=head1 DESCRIPTION

B<Desktop::Notify> is a set of simple bindings to libnotify using NativeCall. Some
function calls are not currently implemented (see the I<TODO> section).

=head2 new(Str $appname)

Constructs a new B<Desktop::Notify> object. It takes one I<mandatory> argument:
B<app-name>, the name of the app that will be registered with the notify dæmon.

=head2 is-initted(--> Bool)

Returns True if the object has been successfully initialized.

=head2 app-name(--> Str)
=head2 app-name(Str $appname --> Nil)

Queries or sets the app name.

=head2 new-notification(Str $summary!, Str $body!, Str $icon! --> NotifyNotification)
=head2 new-notification(Str :$summary!, Str :$body!, Str :$icon!, Int :$timeout?, Str :$category?, NotifyUrgency :$urgency?  --> NotifyNotification)

Creates a new notification.
The first form takes three positional arguments: the summary string, the notification string and
the icon to display (See the libnotify documentation for the available icons).
The second form takes a number of named argument. B<summary>, B<body>, and B<icon> are I<mandatory>,
the others are optional. If B<timeout>, B<category>, and B<urgency> are defined, this method will call
the corresponding "set" methods documented below.

=head2 show(NotifyNotification $notification!, GError $err? --> Bool)

Shows the notification on screen. It takes one mandatory argument, the
NotifyNotification object, and one optional argument, the GError object.
(The default Desktop::Notify error handling is not thread safe. See
I<Threading safety> for more info)

=head2 close(NotifyNotification $notification!, GError $err? --> Bool)

Closes the notification. It takes one mandatory argument, the NotifyNotification
object, and one optional argument, the GError object. (The default
Desktop::Notify error handling is not thread safe. See I<Threading safety> for
more info)
Note that usually there's no need to explicitly 'close' a notification, since
the default is to automatically expire after a while.

=head2 why-closed(NotifyNotification $notification! --> Int)

Returns the the closed reason code for the notification. It takes one argument,
the NotifyNotification object. (See the libnotify documentation for the meaning of
this code)

=head2 get-type(--> Int)

Returns the notification type.

=head2 update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)

Modifies the messages of a notification which is already on screen.

=head2 set-timeout(NotifyNotification $notification!, Int $timeout! --> Nil)

Sets the notification timeout. There are two available constants,
B<NOTIFY_EXPIRES_DEFAULT> and B<NOTIFY_EXPIRES_NEVER>, when explicitly imported
with B<use Desktop::Notify :constants;>.


=head2 set-category(NotifyNotification $notification, Str $category! --> Nil)

Sets the notification category (See the libnotify documentation).

=head2 set-urgency(NotifyNotification $notification, NotifyUrgency $urgency! --> Nil)

Sets the notification urgency. An B<enum NotifyUrgency <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>>
is available when explicitly imported with B<use Desktop::Notify :constants;>.

=head2 server-caps(--> Seq)

Reads server capabilities and returns a sequence.

=head2 server-info(--> Hash)

Reads the server info and returns an hash. The return value of the C function call is
returned as the value of the B<return> key of the hash.

=head1 Threading safety

Desktop::Notify offers a simple interface which provides an B<error> class member,
which is automatically used by the functions which need it.
Since 'error' is a shared class member, if a program makes use of threading, its value
might be written by another thread before it's been read.
In this case one can declare their own GError variables:

=begin code
my $err = Desktop::Notify::GError.new;
=end code

and pass it as an optional argument to the .show() and .close() methods; it will be
used instead of the object-wide one.

=head1 Prerequisites

This module requires the libnotify library to be installed. Please follow the
instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libnotify4
=end code

The module looks for a library called libnotify.so.4, or whatever it finds in
the environment variable B<PERL6_NOTIFY_LIB> (provided that the library one
chooses uses the same API).

=head1 Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

=begin code
$ panda update
$ panda install Desktop::Notify
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

or

=begin code
$ prove6
=end code

=head1 Note

With version 0.2.0 I modified the B<enum NotifyUrgency> to avoid polluting (too much) the namespace.
Now instead of e.g. B<low>, one has to use B<NotifyUrgencyLow>.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
