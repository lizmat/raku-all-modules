use OO::Monitors;
unit monitor Reminders;
use DBIish;

has $!db;
has $!supplier = Supplier::Preserving.new;
has %!waiting;
has $!done = False;

monitor Rem {
    trusts Reminders;
    has      UInt:D $.id    is required;
    has      Str:D  $.what  is required;
    has      Str:D  $.who   is required;
    has      Str:D  $.where is required;
    has  Instant:D  $.when  is required;
    has     Bool:D  $.seen  = False;
    has Reminders   $!rem;

    method !rem($!rem) { self }
    method !from-hash($_) {
        self.bless:
            :id(.<id>.Int), :who(.<who>), :what(.<what>), :where(.<where>),
            :when(Instant.from-posix: .<when>), :seen(?+.<seen>),
            :created(Instant.from-posix: .<created>)
    }
    method !mark-seen   { $!seen = True;  $!rem.mark-seen: self; self }

    method new (|) { die "Cannot instantiate {self.^name} directly" }
    method Str (--> Str:D) {
        my $who-str = $!who ~ ("@" if $!who or $!where) ~ $!where;
        "{"$who-str " if $who-str}$!what"
    }
    method gist (--> Str:D) { self.Str }
}

submethod TWEAK (IO() :$db-file = 'reminders.sqlite.db') {
    my $deploy = $db-file.e.not;
    $!db = DBIish.connect: 'SQLite', :database($db-file.absolute), :RaiseError;
    $deploy and $!db.do: ｢
        CREATE TABLE reminders (
            "id"        INTEGER PRIMARY KEY,
            "who"       TEXT NOT NULL,
            "what"      TEXT NOT NULL,
            "where"     TEXT NOT NULL,
            "when"      TEXT NOT NULL,
            "created"   INTEGER UNSIGNED NOT NULL,
            "seen"      INTEGER UNSIGNED NOT NULL DEFAULT 0
        )
    ｣;
    self!schedule: $_ for self.all;
}

method !schedule(Rem \rem --> Nil) {
    return if rem.seen;
    if rem.when - now < 4 { $!supplier.emit: rem!Rem::mark-seen }
    else {
        %!waiting{rem.id} = True;
        Promise.at(rem.when).then: { self!emit: rem }
    }
}

# keep logic in the method, to guarantee 1-thread use, since it's a monitor class
method !emit(Rem \rem --> Nil) {
    with self.rem: rem.id { # check we still have this reminder in DB
        $!supplier.emit: $_!Rem::mark-seen unless .seen;
    }
    %!waiting{rem.id}:delete;
    $!supplier.done if not %!waiting and $!done;
}

multi method add (UInt:D :$in!, |c --> Reminders:D) {
    self.add: |c, :when(now + $in)
}
multi method add (
            Str:D  \what,
            Str:D  :$who   = '',
            Str:D  :$where = '',
    Instant(Any:D) :$when! where DateTime|Instant
    --> Reminders:D
) {
    $!done and die 'Cannot add more reminders to Reminders object that was .done';
    $!db.do: ｢
        INSERT INTO reminders ("who", "what", "where", "when", "created")
            VALUES (?, ?, ?, ?, ?)
    ｣, $who, what, $where, $when.to-posix.head, time;

    my $rem = do with $!db.prepare:
        ｢SELECT * FROM reminders WHERE id = last_insert_rowid()｣
    {
        LEAVE .finish; .execute;
        my $res := .fetchrow-hash;
        Rem!Rem::from-hash($res)!Rem::rem(self) if $res;
    };
    self!schedule: $rem with $rem;
    self;
}

method all (:$all --> List:D) {
    with $!db.prepare: ｢SELECT * FROM reminders ｣
      ~ (｢WHERE seen == 0｣ unless $all) ~ ｢ ORDER BY "created" DESC, "id" DESC｣
    {
        LEAVE .finish; .execute;
        # https://github.com/perl6/DBIish/issues/93
        eager .allrows(:array-of-hash).map: {
            Rem!Rem::from-hash($_)!Rem::rem(self)
        };
    }
}

method done (--> Nil) {
    $!done = True;
    $!supplier.done unless %!waiting;
}

multi method mark-seen (UInt:D \id --> Nil) {
    self.mark-seen: $_ with self.rem: id;
}
multi method mark-seen (Rem:D $rem --> Nil) {
    $!db.do: ｢UPDATE reminders SET seen = 1 WHERE id = ?｣, $rem.id
}
multi method mark-unseen (UInt:D \id, :$re-schedule --> Nil) {
    self.mark-unseen: $_, :$re-schedule with self.rem: id;
}
multi method mark-unseen (Rem:D $rem, :$re-schedule --> Nil) {
    $!db.do: ｢UPDATE reminders SET seen = 0 WHERE id = ?｣, $rem.id;
    self!schedule: self.rem: $rem.id if $re-schedule;
}

method rem (UInt:D \id --> Rem:D) {
    with $!db.prepare: ｢SELECT * FROM reminders WHERE id = ?｣ {
        LEAVE .finish; .execute: id;
        my $res := .fetchrow-hash;
        return Rem!Rem::from-hash($res)!Rem::rem(self) if $res;
    }
    Nil
}

multi method remove (UInt:D \id --> Nil) {
    self.remove: $_ with self.rem: id;
}
multi method remove (Rem:D \rem --> Nil) {
    $!db.do: ｢DELETE FROM reminders WHERE id = ?｣, rem.id;
    %!waiting{rem.id}:delete;
}

multi method snooze (UInt:D \id, |c --> Rem:D) {
    self.snooze: $_, |c with self.rem: id;
}
multi method snooze (UInt:D :$in!, |c --> Rem:D) {
    self.snooze: |c, :when(now + $in)
}
multi method snooze (
    Rem:D \rem, Instant(Any:D) :$when! where DateTime|Instant --> Rem:D
) {
    $!done and die 'Cannot snooze because Reminders object was .done already';
    $!db.do: ｢UPDATE reminders SET seen = 0, "when" = ? WHERE id = ?｣,
        $when.to-posix.head, rem.id;
    %!waiting{rem.id}:delete;
    with self.rem: rem.id {
        self!schedule: $_;
        $_
    }
}

method Supply (--> Supply:D) { $!supplier.Supply }
