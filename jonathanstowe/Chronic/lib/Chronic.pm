use v6;

=begin pod

=head1 NAME

Chronic - provide low level scheduling facility

=head1 SYNOPSIS

=begin code

# Static configuration;

use Chronic;

react {
    # Every minute
    whenever Chronic.every() -> $v {
        say "One: $v";
    }
    # Every five minutes
    whenever Chronic.every(minute => '*/5') -> $v {
        say "Five: $v";
    }
    # At 21:31 every day
    whenever Chronic.every(minute => 31, hour => 21) -> $v {
        say "21:31 $v";
    }

}

# Dynamic configuration

use Chronic;

my @events = (
    {
        schedule => {},
        code     => sub ($v) { say "One: $v" },
    },
    {
        schedule => { minute => '*/2' },
        code     => sub ($v) { say "Two: $v" },
    },
    {
        schedule => { minute => '*/5' },
        code     => sub ($v) { say "Five: $v" },
    },
    {
        schedule => { minute => 31, hour => 21 },
        code     => sub ($v) {  say "21:31 $v"; },
    },
);

for @events -> $event {
    Chronic.every(|$event<schedule>).tap($event<code>);
}

# This has the effect of waiting forever
Chronic.supply.wait;

=end code

=head1 DESCRIPTION

This module provides a low-level scheduling mechanism, that be used to
create cron-like schedules, the specifications can be provided as cron
expression strings, lists of integer values or L<Junctions> of values.

There is a class method C<every> that takes a schedule specification
and returns a L<Supply> that will emit a value (a L<DateTime>) on the
schedule specified. There is also a class method C<at> that returns
a Promise that will be kept at the specified time.

This can be used to build custom scheduling services like C<cron> with
additional code to read the specification from a file and arrange the
execution of the required thing or it could be used in a larger program
that may require to execute some code asynchronously periodically.

There is a single base Supply that emits an event at a 1 second frequency
in order to preserve the accuracy of the timings (in testing it may drift
by up to 59 seconds on a long run due to system latency if it didn't 
match the seconds too,) so this may be a problem on a heavily loaded
single core computer. The sub-minute granularity isn't provided for in
the interface as it is easily achieved anyway with a basic supply, it
isn't supported by a standard C<cron> and I think most code that would
want to be executed with that frequency would be more highly optimised then
this may allow.


=head1 METHODS

=head2 method every

    method every(*%args) returns Supply

This returns a L<Supply> that will emit a value (a L<DateTime>
indicating when the event was fired,) at the frequency specified by the
arguments. The arguments are infact passed directly to the constructor
of C<Chronic::Description> (described below,) which is used to match
the times that an event should occur.

=head2 method at

    multi method at(Int $i) returns Promise
    multi method at(Instant:D $i) returns Promise
    multi method at(Str:D $d) returns Promise
    multi method at(DateTime $d) returns Promise

This takes a datetime specification (either a L<DateTime> object,
a L<Str> that can be parsed as a DateTime, an L<Instant> or an L<Int>
representing the epoch seconds,) and returns a L<Promise> which will be
kept with a DateTime when that time arrives.  If the supplied datetime
specification resolves to the current time or is in the past the Promise
will be returned Kept. The resolution of the comparison is at the second
level (as with C<every> above,) and any fractional part in the presented
DateTime will be truncated.

If you want to do something at some time period from the current time
then you may actually be better off using the C<in> method of L<Promise>
which returns a Promise that will be kept a certain number of seconds
in the future.

=head2 method supply

   method supply() returns Supply

This is the base supply that emits the L<DateTime> at 1 second intervals,
it is used internally but exposed in the possibility that it may be useful
as in the synopsis for example.

=head1 Chronic::Description

This is the class that is used to match the L<DateTime> against the frequency
specification, all of the attributes are an C<any> L<Junction> and by default
will match any allowed value for the period unit (hence the default is a one
minute frequency.)  

The constructor allows the unit specifications to provided as Junctions,
lists of integers, single integer values or strings in the form of cron
specifications for that unit:


     A field may be an asterisk (*), which always stands for ``first-last''.

     Ranges of numbers are allowed.  Ranges are two numbers separated with a
     hyphen.  The specified range is inclusive.  For example, 8-11 for an
     ``hours'' entry specifies execution at hours 8, 9, 10 and 11.

     Lists are allowed.  A list is a set of numbers (or ranges) separated by
     commas.  Examples: ``1,2,5,9'', ``0-4,8-12''.

     Step values can be used in conjunction with ranges.  Following a range
     with ``/<number>'' specifies skips of the number's value through the
     range.  For example, ``0-23/2'' can be used in the hours field to specify
     command execution every other hour (the alternative in the V7 standard is
     ``0,2,4,6,8,10,12,14,16,18,20,22'').  Steps are also permitted after an
     asterisk, so if you want to say ``every two hours'', just use ``*/2''.

(From the L<FreeBSD manpage from crontab(5)|https://www.freebsd.org/cgi/man.cgi?crontab(5)>). For brevity only the names and ranges of the values are
described.  The "name" forms for C<month> and C<day-of-week> are currently
not supported because the localisation issues seemed more trouble than it's
worth.

The allowed arguments to the constructor (and attributes of the class) are:

=head2 minute

The minutes in the specifcation should be matched in the range 0 .. 59

=head2 hour

The hours that should be matched in the specification in the range 0 .. 23

=head2 day

The days that should be matched in the specification, in the range 0 .. 31
clearly not all months have all those days, but "step" specifications should
have the same effect for e.g. "every three days".

=head2 month

The months that should be matched in the specification in the range 1 .. 12

=head2 day-of-week

The day of the week (starting on Monday) in the range 1 .. 7

=end pod

class Chronic:ver<0.0.3>:auth<github:jonathanstowe> {
    class Description {

        sub expand-expression(Str $exp, Range $r) returns Array[Int] {
            my Int @values;

            my ($top, $divisor) = $exp.split('/');

            sub explode-item(Str $v) {
	            if $v.contains('-') {
		            my ( $min, $max ) = $v.split('-');
		            my Range $r = $min.Int .. $max.Int;
		            $r.list;
	            }
	            else {
		            $v;
                }
            }

            if $top eq '*' {
                @values = $r.list;
            }
            else {
                @values = $top.split(',').flatmap(&explode-item).map(*.Int);
            }

            if $divisor.defined {
                @values = @values.grep( * %% $divisor.Int);
            }

            @values;
        }

        my Range $minute-range = 0 .. 59;
        multi sub get-minutes(Whatever $) {
            get-minutes($minute-range);
        }
        multi sub get-minutes('*') {
            get-minutes(*);
        }
        multi sub get-minutes(Str $exp) {
            my Int @m = expand-expression($exp, $minute-range);
            get-minutes(@m);
        }
        multi sub get-minutes(Range $r where {all($_.list) ~~ $minute-range}) {
            my Int @m = $r.list;
            get-minutes(@m);
        }
        multi sub get-minutes(*@m where { all($_.list) ~~ $minute-range }) {
            get-minutes(@m);
        }
        multi sub get-minutes(@m where { all($_.list) ~~ $minute-range }) {
            any(@m);
        }
        has Junction $.minute       is rw = get-minutes(*);

        my Range $hour-range = 0 .. 23;
        multi sub get-hours(Whatever $) {
            get-hours($hour-range);
        }
        multi sub get-hours('*') {
            get-hours(*);
        }
        multi sub get-hours(Str $exp) {
            my Int @m = expand-expression($exp, $hour-range);
            get-hours(@m);
        }
        multi sub get-hours(Range $r where {all($_.list) ~~ $hour-range}) {
            my Int @m = $r.list;
            get-hours(@m);
        }
        multi sub get-hours(*@m where { all($_.list) ~~ $hour-range }) {
            get-hours(@m);
        }
        multi sub get-hours(@m where { all($_.list) ~~ $hour-range }) {
            any(@m);
        }
        has Junction $.hour         is rw = get-hours(*);

        my Range $day-range = 1 .. 31;
        multi sub get-days(Whatever $) {
            get-days($day-range);
        }
        multi sub get-days('*') {
            get-days(*);
        }
        multi sub get-days(Str $exp) {
            my Int @m = expand-expression($exp, $day-range);
            get-days(@m);
        }
        multi sub get-days(Range $r where {all($_.list) ~~ $day-range}) {
            my Int @m = $r.list;
            get-days(@m);
        }
        multi sub get-days(*@m  where { all($_.list) ~~ $day-range }) {
            get-days(@m);
        }
        multi sub get-days(@m where { all($_.list) ~~ $day-range }) {
            any(@m);
        }
        has Junction $.day          is rw = get-days(*);

        my Range $month-range = 1 .. 12;
        multi sub get-months(Whatever $) {
            get-months($month-range);
        }
        multi sub get-months('*') {
            get-months(*);
        }
        multi sub get-months(Str $exp) {
            my Int @m = expand-expression($exp, $month-range);
            get-months(@m);
        }
        multi sub get-months(Range $r where { all($_.list) ~~ $month-range }) {
            my Int @m = $r.list;
            get-months(@m);
        }
        multi sub get-months(*@m where { all($_.list) ~~ $month-range }) {
            get-months(@m);
        }
        multi sub get-months(@m where { all($_.list) ~~ $month-range }) {
            any(@m);
        }
        has Junction $.month        is rw = get-months(*);

        my Range $dow-range = 1 .. 7;
        multi sub get-dows(Whatever $) {
            get-dows($dow-range);
        }
        multi sub get-dows('*') {
            get-dows(*);
        }
        multi sub get-dows(Str $exp) {
            my Int @m = expand-expression($exp, $dow-range);
            get-dows(@m);
        }
        multi sub get-dows(Range $r where {all($_.list) ~~ $dow-range}) {
            my Int @m = $r.list;
            get-dows($r.list);
        }
        multi sub get-dows(*@m where { all($_.list) ~~ $dow-range }) {
            get-dows(@m);
        }
        multi sub get-dows(@m where { all($_.list) ~~ $dow-range }) {
            any(@m);
        }
        has Junction $.day-of-week  is rw = get-dows(*);


        my %params = (
            minute      =>  &get-minutes,
            hour        =>  &get-hours,
            day         =>  &get-days,
            month       =>  &get-months,
            day-of-week =>  &get-dows
        );

        multi method new(*%args) {
            my %new-args;

            for %args.kv -> $k, $v {
                if %params{$k}:exists {
                    %new-args{$k} = do if $v ~~ Junction {
                        $v;
                    }
                    else {
                        %params{$k}($v);
                    }
                }
            }
            self.bless(|%new-args);
        }

        multi method ACCEPTS(DateTime $d) returns Bool {
            $d.second.Int   == 0        &&
            $d.minute       ~~ $!minute &&
            $d.hour         ~~ $!hour   &&
            $d.day          ~~ $!day    &&
            $d.month        ~~ $!month  &&
            $d.day-of-week  ~~ $!day-of-week;
        }
    }

    #| This is a single supply for all clients in the process
    my Supply $supply;

    #| access the single supply creating it if necessary
    method supply() {
        if not $supply.defined {
            $supply = Supply.on-demand( -> $p {
                Supply.interval(1).tap({ $p.emit(DateTime.now.truncated-to('second')); });
            });
        }
        $supply;
    }

    #| create a supply that fires on the time specification
    method every(*%args) returns Supply {
        my $description = Description.new(|%args);
        my $supply = self.supply.grep($description);
        $supply;
    }

    multi method at(Int $i) returns Promise {
        samewith(DateTime.new($i));
    }
    multi method at(Instant:D $i) returns Promise {
        samewith(DateTime.new($i));
    }
    multi method at(Str:D $d) returns Promise {
        samewith(DateTime.new($d));
    }
    multi method at(DateTime $d) returns Promise {
        my $datetime = $d.truncated-to('second');
        my $promise = Promise.new;
        my $v = $promise.vow;

        if $datetime <= DateTime.now.truncated-to('second') {
            $v.keep($datetime);
        }
        else {
            my $tap = self.supply.grep({ $_ == $datetime }).tap({
                $tap.close;
                $v.keep($_);
            });
        }
        $promise;
    }
}

use MONKEY-TYPING;

augment class DateTime {
    multi method ACCEPTS(Chronic::Description $d) returns Bool {
        self.second.Int   == 0         &&
        self.minute       ~~ $d.minute &&
        self.hour         ~~ $d.hour   &&
        self.day          ~~ $d.day    &&
        self.month        ~~ $d.month  &&
        self.day-of-week  ~~ $d.day-of-week;
    }
    
}

# vim: ft=perl6 expandtab sw=4
