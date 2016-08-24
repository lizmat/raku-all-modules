## Desktop::Notify

Desktop::Notify is a set of simple bindings to libnotify using NativeCall.

## Example

```Perl6
use v6;
use Desktop::Notify;

my $notify = Desktop::Notify.new(app-name => 'myapp');
my $n = $notify.new-notification('Attention!', 'What just happened?', 'stop');

$notify.set-timeout($n, NOTIFY_EXPIRES_NEVER);

$notify.show($n);
sleep 2;

$notify.update($n, 'Oh well!', 'Not quite a disaster!', 'stop');

$notify.show($n);
```

If you run this code, note that the notification doesn't fade by itself,
but you need to click on it in order to close it.

For more examples see the `example` directory.

## Documentation

#### new(Str $appname)

Constructs a new `Desktop::Notify` object. It takes one **mandatory** argument:
`app-name`, the name of the app that will be registered with the notify dæmon.

#### is-initted(--> Bool)

Returns True if the object has been successfully initialized.

#### app-name(--> Str)
#### app-name(Str $appname --> Nil)

Queries or sets the app name.

#### new-notification(Str $summary!, Str $body!, Str $icon! --> NotifyNotification)
#### new-notification(Str :$summary!, Str :$body!, Str :$icon!, Int :$timeout?, Str :$category?, NotifyUrgency :$urgency?  --> NotifyNotification)

Creates a new notification.
The first form takes three positional arguments: the summary string, the notification string and
the icon to display (See the libnotify documentation for the available icons).
The second form takes a number of named argument. `summary`, `body`, and `icon` are **mandatory**,
the others are optional. If `timeout`, `category`, and `urgency` are defined, this method will call
the corresponding "set" methods documented below.

#### show(NotifyNotification $notification!, GError $err? --> Bool)

Shows the notification on screen. It takes one mandatory argument, the
NotifyNotification object, and one optional argument, the GError object.
(The default Desktop::Notify error handling is not thread safe. See `Threading safety`
for more info)

#### close(NotifyNotification $notification!, GError $err? --> Bool)

Closes the notification. It takes one mandatory argument, the NotifyNotification
object, and one optional argument, the GError object. (The default
Desktop::Notify error handling is not thread safe. See `Threading safety` for
more info)
Note that usually there's no need to explicitly `close` a notification, since
the default is to automatically expire after a while.

#### why-closed(NotifyNotification $notification! --> Int)

Returns the the closed reason code for the notification. It takes one argument,
the NotifyNotification object. (See the libnotify documentation for the meaning of
this code)

#### get-type(--> Int)

Returns the notification type.

#### update(NotifyNotification $notification!, Str $summary, Str $body, Str $icon --> Bool)

Modifies the messages of a notification which is already on screen.

#### set-timeout(NotifyNotification $notification!, Int $timeout! --> Nil)

Sets the notification timeout. There are two available constants,
`NOTIFY_EXPIRES_DEFAULT` and `NOTIFY_EXPIRES_NEVER`, when explicitly imported
with `use Desktop::Notify :constants;`.

#### set-category(NotifyNotification $notification, Str $category! --> Nil)

Sets the notification category (See the libnotify documentation).

#### set-urgency(NotifyNotification $notification, NotifyUrgency $urgency! --> Nil)

Sets the notification urgency. An `enum NotifyUrgency <NotifyUrgencyLow NotifyUrgencyNormal NotifyUrgencyCritical>`
is available when explicitly imported with `use Desktop::Notify :constants;`.

#### server-caps(--> Seq)

Collects the server capabilities and returns a sequence.

#### server-info(--> Hash)

Reads the server info and returns an hash. The return value of the C function call is
returned as the value of the `return` key of the hash.

## Threading safety

Desktop::Notify offers a simple interface which provides an `error` class member,
which is automatically used by the functions which need it.
Since `error` is a shared class member, if a program makes use of threading, its value
might be written by another thread before it's been read.
In this case one can declare their own GError variables:

```
my $err = Desktop::Notify::GError.new;
```

and pass it as an optional argument to the .show() and .close() methods; it will be
used instead of the object-wide one.

## Prerequisites
This module requires the libnotify library to be installed. Please follow the
instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libnotify4
```

The module looks for a library called libnotify.so.4, or whatever it finds in
the environment variable `PERL6_NOTIFY_LIB` (provided that the library one
chooses uses the same API).

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install Desktop::Notify
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

or

```
$ prove6
```

## Note

With version 0.2.0 I modified the `enum NotifyUrgency` to avoid polluting (too much) the namespace.
Now instead of e.g. `low`, one has to use `NotifyUrgencyLow`.

## Author

Fernando Santagata

## License

The Artistic License 2.0
