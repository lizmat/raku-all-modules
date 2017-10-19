[![Build Status](https://travis-ci.org/zoffixznet/perl6-Reminders.svg)](https://travis-ci.org/zoffixznet/perl6-Reminders)

# NAME

`Reminders` - Class for managing reminders about tasks and events

# SYNOPSIS

```perl6
    use Reminders;

    my Reminders $rem .= new; # use default 'reminders.sqlite.db' db file
    say "Setting up some reminders up to 20 seconds in the future";
    $rem.add: '5 seconds passed',  :5in;
    $rem.add: '15 seconds passed', :when(now+15), :who<Zoffix>, :where<#perl6>;

    react whenever $rem {
        say "Reminder: $^reminder";
        once $rem.add('One more thing, bruh', :15in).done;
    }

    # OUTPUT (exits after printing last line):
    # Reminder: 5 seconds passed
    # Reminder: Zoffix@#perl6 15 seconds passed
    # Reminder: One more thing, bruh
```

```perl6
    use Reminders;

    my Reminders $rem .= new;
    $rem.add: 'one', :who<Zoffix>, :where<space>, :1in;
    $rem.add: 'two', :who<Meows>,  :where<perl6>, :2in;

    react whenever $rem -> $r {
        say "Reminder: $r.what() [$r.who() / $r.where()]";
        once {
            $rem.snooze: $r, :3in;
            $rem.done;
        }
    }

    # OUTPUT (exits after printing last line):
    # Reminder: one [Zoffix / space]
    # Reminder: two [Meows / perl6]
    # Reminder: one [Zoffix / space]
```

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [METHODS](#methods)
    - [monitor `Reminders`](#monitor-reminders)
        - [method `.new`](#method-new)
        - [method `.add`](#method-add)
        - [method `.all`](#method-all)
        - [method `.done`](#method-done)
        - [method `.mark-seen`](#method-mark-seen)
        - [method `.mark-unseen`](#method-mark-unseen)
        - [method `.rem`](#method-rem)
        - [method `.remove`](#method-remove)
        - [method `.snooze`](#method-snooze)
        - [method `.Supply`](#method-supply)
    - [monitor `Reminders::Rem`](#monitor-remindersrem)
        - [method `.new`](#method-new-1)
        - [method `.id`](#method-id)
        - [method `.what`](#method-what)
        - [method `.who`](#method-who)
        - [method `.where`](#method-where)
        - [method `.when`](#method-when)
        - [method `.Str`](#method-str)
        - [method `.gist`](#method-gist)
- [MULTI-THREADING](#multi-threading)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# DESCRIPTION

You ask the class to remind you with stuff, tagged with an optional name and
location. When the time comes, the class will emit the reminder to a `Supply`.
The reminders are stored in an SQLite database, so even if you close the
program, you will still get your reminders the next time you fire it up.

# METHODS

## monitor `Reminders`

### method `.new`

```perl6
    submethod TWEAK(IO() :$db-file = 'reminders.sqlite.db')
```

Creates a new `Reminders` object. Takes an optional `:$db-file` named arg
specifying the SQLite database file location. The file will be automatically
created and SQL schema deployed if the file does not exist.

If the database has any unseen reminders with their due times reached, they
will be emited.

```perl6
    my Reminders $rem .= new;
    my Reminders $rem-custom .= new: :db-file<my-special-reminders.db>;
```

### method `.add`

```perl6
    multi method add (UInt:D :$in!, |c --> Reminders:D)
    multi method add (
                Str:D  \what,
                Str:D  :$who   = '',
                Str:D  :$where = '',
        Instant(Any:D) :$when! where DateTime|Instant
        --> Reminders:D
    )
```

Returns the invocant. Adds a new reminder as string `what` to be emitted at the
`:$when` `Instant`. If `:$in` argument is used, the call is re-done with `:$when`
set to [`now`](https://docs.perl6.org/routine/now) plus `$in` seconds.
It's invalid to set both `:$in` and `:$when` at the same time.

Reminders with `:$when` set in the past are allowed and will be emitted immediately. If `:$when` is up to 10 seconds in the future from
[`now`](https://docs.perl6.org/routine/now), the reminder may be emitted
immediately.

Optional `:$who` and `:$where` arguments can be provided for arbitrary
classification of the reminder (these will be available via methods of the
emitted object).

```perl6
    $rem.add: 'one', :5in;       # may  be emitted immediately
    $rem.add: 'two', :in(-1000); # will be emitted immediately
    $rem.add: 'three', :when(DateTime.now.later: :year), # will be scheduled
              :who<Zoffix>, :where<#perl6>;
```

### method `.all`

```perl6
    method all (:$all --> List:D)
```

Returns a possibly-empty `List` of `Reminder::Rem` objects representing all
currently-unseen reminders, ordered by creation time, in descending order.
If `:$all` is set to a truthy value, returns all reminders in the database,
including those marked as seen.

```perl6
    .say for flat "You have these unseen reminders: ", $rem.all;
    # OUTPUT:
    # You have these unseen reminders:
    # get starship fuel

    .say for flat  "These are the reminders in the database: ", $rem.all: :all;
    # OUTPUT:
    # These are the reminders in the database:
    # pick up milk
    # get starship fuel
```

### method `.done`

```perl6
    method done (--> Nil)
```

Calls [`done`](https://docs.perl6.org/type/Supplier#method_done) on the
[`Supplier`](https://docs.perl6.org/type/Supplier) responsible for the
[`Supply`](https://docs.perl6.org/type/Supply) of reminder objects, one all
of them have been emitted.

Calling this method is optional and is just a convenience to break out of,
say, `react` loops. It's not permitted to `.add` more reminders once this
method have been called.

```perl6
    my Reminders $rem .= new;
    $rem.add: 'one', :3in;
    $rem.add: 'two', :5in;
    $rem.done;
    react whenever $rem { say "Reminder: $^reminder" }

    # OUTPUT (automatically exits after last line):
    # Reminder: one
    # Reminder: two
```

### method `.mark-seen`

```perl6
    multi method mark-seen (UInt:D \id --> Nil)
    multi method mark-seen (Reminders::Rem:D $rem --> Nil)
```

Takes a reminder object or just its `id` and marks it as "seen". Reminders
emitted into the `.Supply` are marked as "seen" automatically when emitted.

```perl6
    $rem.mark-seen: $_ for $rem.all.grep: *.what.contains: 'stuff I done already';
```

Marking an emitted reminder as "seen" will prevent it from being emitted, even
if it was already scheduled.

### method `.mark-unseen`

```perl6
    multi method mark-unseen (UInt:D \id, :$re-schedule --> Nil)
    multi method mark-unseen (Reminders::Rem:D $rem, :$re-schedule --> Nil)
```

Takes a reminder object or just its `id` and marks it as "unseen".
If `:$re-schedule` named argument is set to a truthy value, the reminder will
also be re-scheduled; note that if reminder's `.when` is in the past, that will
cause it to be immediately emitted and again marked as "seen".

```perl6
    $rem.mark-unseen: $_, :re-schedule
        for $rem.all.grep: *.what.contains: 'stuff I forgot to do';
```

### method `.rem`

```perl6
    method rem (UInt:D \id --> Reminders::Rem:D)
```

Takes an id of a reminder and returns the reminder object for it, or `Nil`
if a reminder with such an id was not found.

```perl6
    say "You're meant to do: " ~ $rem.rem(2).what;
```

### method `.remove`

```perl6
    multi method remove (UInt:D \id --> Nil)
    multi method remove (Reminders::Rem:D \rem --> Nil)
```

Takes a reminder object or its ID and deletes it from the database and prevents
it from being emitted if it was already scheduled (note that the internal
scheduling `Promise` will still exist until it fires, it just won't emit the
reminder when it does).

```perl6
    $rem.remove: $_ for $rem.all.grep: *.what.contains: 'things I done';
```

### method `.snooze`

```perl6
multi method snooze (UInt:D \id, |c --> Reminders::Rem:D)
multi method snooze (UInt:D :$in!, |c --> Reminders::Rem:D)
multi method snooze (
    Reminders::Rem:D \rem, Instant(Any:D) :$when! where DateTime|Instant
    --> Reminders::Rem:D
)
```

Takes a reminder object or its ID, marks it unseen and adjusts `.when` to a
new value given via `:$in` or `:$when` named arguments (same semantics as
in `.add` method). Returns the updated reminder object. It's not permitted
to `.snooze` after `Reminders` was `.done`


```perl6
    my Reminders $rem .= new;
    $rem.add: 'one', :who<Zoffix>, :where<space>, :1in;
    $rem.add: 'two', :who<Meows>,  :where<perl6>, :2in;

    react whenever $rem -> $r {
        say "Reminder: $r.what() [$r.who() / $r.where()]";
        once {
            $rem.snooze: $r, :3in;
            $rem.done;
        }
    }

    # OUTPUT (exits after printing last line):
    # Reminder: one [Zoffix / space]
    # Reminder: two [Meows / perl6]
    # Reminder: one [Zoffix / space]
```

### method `.Supply`

```perl6
    method Supply (--> Supply:D)
```

Returns a [`Supply`](https://docs.perl6.org/type/Supply) of emitted reminder
objects that are emited at their `:$when`/`:$in` times. The `Supply` is
managed by
[`Supplier::Preserving`](https://docs.perl6.org/type/Supplier::Preserving)

## monitor `Reminders::Rem`

A reminder object emitted into `Reminders.Supply` that represents a reminder.

### method `.new`

This object cannot be instantiated directly.

### method `.id`

Returns a `UInt` with reminder object's ID. This is the ID accepted by
several `Reminders`'s methods.

### method `.what`

Returns a `Str:D` containing the message of the reminder. This is the `what`
given to `Reminders.add` method.

### method `.who`

Returns a `Str:D` containing the value of `:$who` that was
given to `Reminders.add` method.

### method `.where`

Returns a `Str:D` containing the value of `:$where` that was
given to `Reminders.add` method.

### method `.when`

Returns an `Instant:D` containing the value of when the reminder was scheduled
for. This value is interpreted from `:$in` or `:$when` value given to
`Reminders.add` method.

### method `.Str`

Returns a `Str:D` composed of the reminder's `.what` value, preceeded by
string `$who@$what` if either `.who` or `.what` value is non-empty.

### method `.gist`

Calls `.Str` and returns its value.

# MULTI-THREADING

`Reminders` type is a [monitor](https://modules.perl6.org/dist/OO::Monitors),
so it's safe to multi-thread its methods.

However, currently, trying to use the **same database file** from multiple programs
or multiple `Reminders` instances might have issues due to race conditions or
crashes if SQLite or [`DBIish`](https://modules.perl6.org/dist/DBIish)
are not thread safe (no idea if they are).

---

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Reminders

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Reminders/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
