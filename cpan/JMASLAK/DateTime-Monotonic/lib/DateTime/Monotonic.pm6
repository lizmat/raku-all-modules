use v6.c;

#
# Copyright © 2018 Joelle Maslak
# All Rights Reserved - See License
#

unit class DateTime::Monotonic:ver<0.0.4>:auth<cpan:JMASLAK>;

use NativeCall;

# Public Attributes
has Bool:D $.has-monotonic-support = INIT { Kernel.new.name eq 'linux' }; # Only Linux supported now
has Bool:D $.use-syscall           = $!has-monotonic-support;  # Default to available value

# Private Attributes
has Numeric $!last-time;                # Last time value returned
has Numeric $!offset;                   # Currently applied offset
has Lock:D  $!lock = Lock.new;

# Used for Testing Only
# Normally not used, but if this value is set, it's used instead of the
# standard clock call (I.E. clock_gettime or DateTime.now)
# This is not to be documented in POD, as it's not supposed to be
# user-visible.
#
# Note that if this is set, AND use-syscall is set, then we'll throw
# exceptions when second() is called if this ends up moving backwards.
has Numeric $.testing-clock-time is rw;

# Private Native Call Linux Definitions
my constant \CLOCK_MONOTONIC = 1;
my class Timespec-Linux is repr('CStruct') {
    has long $.tv_sec;
    has long $.tv_nsec;
}
my sub Linux-clock_gettime(int32, Timespec-Linux -->int32) is native is symbol('clock_gettime') { * }

# Sub to do the system call
my sub Linux-syscall-seconds(-->Numeric:D) {
    my $ts = Timespec-Linux.new;
    Linux-clock_gettime(CLOCK_MONOTONIC, $ts);
    return $ts.tv_sec + ( $ts.tv_nsec / 1_000_000_000 );
}
my sub syscall-seconds(-->Numeric:D) {
    # Just do Linux for now.
    return Linux-syscall-seconds;
}

# And sub to do this with datetime
my sub datetime-seconds(-->Numeric:D) {
    my $now = DateTime.now;
    return $now.posix + ($now.second - $now.whole-second);
}

# Methods
method seconds(-->Numeric:D) {
    #
    # We want the time to always stay the same and/or move forward.
    # If for some reason the available clock (put into $val) moves
    # backwards, we treat it instead like it's exactly the same time
    # since the last call to seconds(), and we return the old time.
    #
    # We normalize the time - the first call to seconds() will return
    # "time zero" or a value of 0.
    #
    
    $!lock.protect: {
        # Get the clock time, using syscall or the fallback if we can't use
        # syscall.
        my $val;
        if $!testing-clock-time.defined {
            $val = $!testing-clock-time;
        } elsif $!use-syscall {
            $val = syscall-seconds;
        } else {
            $val = datetime-seconds;
        }

        # Special case - first time through, so it's time zero
        if ! $!last-time.defined {
            $!offset = 0 - $val;  # Make this "Time Zero"
            $!last-time = 0;
            return 0;
        }

        # If time is not moving backwards, we're good!  Return the time.
        if ($val + $!offset) ≥ $!last-time {
            $!last-time = $val + $!offset;
            return $!last-time;
        }

        # Time appears to have went backwards!
        # That can't happen for monotonic time.  It's a bug somewhere.
        if $!use-syscall { die("Monotonic ime appears to have moved backwards"); }

        # We need to come up with a new offset.  Last time is unchanged (we
        # hand back exactly the same time)
        $!offset = $!last-time - $val;

        return $!last-time
    }
}

#
#  Procedural Interface
#

my DateTime::Monotonic:D $time = DateTime::Monotonic.new;

our sub monotonic-seconds(-->Numeric) is export(:monotonic-seconds, :ALL) {
    return $time.seconds;
}

our sub monotonic-whole-seconds(-->Int) is export(:monotonic-whole-seconds, :ALL) {
    return monotonic-seconds.truncate;
}

=begin pod

=head1 NAME

DateTime::Monotonic - is a Never-Decreasing Time-Elapsed Counter

=head1 SYNOPSIS

  #
  # Procedural Interface
  #
  use DateTime::Monotonic :ALL;

  my $start = monotonic-seconds;
  # Do something that takes time here
  my $end = monotonic-seconds;

  say "Processing took at least {$end - $start} seconds";


  #
  # OO Interface
  #

  use DateTime::Monotonic;

  my $tm = DateTime::Monotonic.new;

  my $start = $tm.seconds;
  # Do something that takes time here
  my $end = $tm.seconds;

  say "Processing took at least {$end - $start} seconds";

=head1 DESCRIPTION

DateTime::Monotonic is A Never-Decreasing Time-Elapsed Counter.

This means that for any given instance of C<DateTime::Monotonic>, the
time will always increment, never decrement, even if the system clock
is adjusted.

On Linux, this will use a monotonic second counter that is independent
of the time-of-day clock.  This allows reasonably accurate time
measurements independent of the system clock being changed.

On non-Linux hosts, this will simulate a monotonic second counter by
treating negative time shifts between successive calls to C<seconds>
as if no time elapsed.  It will continue to be impacted by time shifts
forward.

The procedural iterface uses a single, global, instance of
C<DateTime::Monotonic> initialized with default options.  The OO instance
allows multiple independent, instances of C<DateTime::Monotonic> to be
created.  Each one independently starts counting from the first call of
C<seconds> on that instance.

=head1 Procedural Interface

The procedural interface provides a simple way of accessing a
globally-shared (within program scope) monotonic clock.  It starts
counting from the first access ("time zero").

To export all symbols, import the C<:ALL> tag.  Each procedure also
has a tag (the name of the sub, prefaced by a colon) by which it is
exported.

=head2 monotonic-seconds(-->Numeric:D)

Returns relative time between this call and the first procedural interface
call.

On the first procedural call, this will return "time zero" which is the value
C<0>. Following calls to C<seconds> will return the time elapsed (in seconds,
including fractional seconds) since this "time zero".

On Linux systems, this will provide reasonably accurate time regardless
of system clock adjustement.

On Non-Linux systems, this will provide an always-incrementing number
which will not be accurate with adjustments.  If the time-of-day clock
would indicate time went backwards between the procedural call and the
previous procedural call, this sub will return the previous result
(I.E. the number returned will be the same as if no time elapsed between
calls).  If time is adjusted forward between calls, this will return a
value that appears to have caused more time to elapse than actually has
elapsed - but it will always be in a forward direction.

This sub is thread safe.

=head2 monotonic-whole-seconds(-->Int:D)

This is merely a wrapper around C<monotonic-seconds> that provides the
same result as C<monotonic-seconds> but without the decimal component.

This sub is thread safe.

=head1 ATTRIBUTES

=head2 has-monotonic-support

This is C<True> on systems with monotonic counters that are supported
by this module (currently just Linux).  If true, you can measure time
elapsed reasonably accurately even if the system clock is adjusted.

If this is C<False>, the monotonic support is emulated, subject to the
limitations described below under C<seconds>.

=head1 METHODS

=head2 seconds(-->Numeric:D)

Returns relative time between this C<seconds> call and the first
C<seconds> call of this instance of C<DateTime::Monotonic>.

On the first call for an instance of C<DateTime::Monotonic>, will return
"time zero" which is the value C<0>. Following calls to C<seconds> will
return the time elapsed (in seconds, including fractional seconds) since
this "time zero".

On Linux systems, this will provide reasonably accurate time regardless
of system clock adjustement.

On Non-Linux systems, this will provide an always-incrementing number
which will not be accurate with adjustments.  If the time-of-day clock
would indicate time went backwards between a C<seconds> call and the
previous C<seconds> call, this method will return the previous result
(I.E. the number returned will be the same as if no time elapsed between
calls).  If time is adjusted forward between calls, this will return a
value that appears to have caused more time to elapse than actually has
elapsed - but it will always be in a forward direction.

This method is thread safe.

=head1 BUGS

While there are no known bugs, this module does not yet support non-Linux
OSes fully.  It will provide non-reversing time on those systems, but the
module could be improved by adding additional OS support.

=head1 EXPRESSING APPRECIATION

If this module makes your life easier, or helps make you (or your workplace)
a ton of money, I always enjoy hearing about it!  My response when I hear that
someone uses my module is to go back to that module and spend a little time on
it if I think there's something to improve - it's motivating when you hear
someone appreciates your work!

I don't seek any money for this - I do this work because I enjoy it.  That
said, should you want to show appreciation financially, few things would make
me smile more than knowing that you sent a donation to the Gender Identity
Center of Colorado (See L<http://giccolorado.org/>.  This organization
understands TIMTOWTDI in life and, in line with that understanding, provides
life-saving support to the transgender community.

If you make any size donation to the Gender Identity Center, I'll add your name
to "MODULE PATRONS" in this documentation!

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
