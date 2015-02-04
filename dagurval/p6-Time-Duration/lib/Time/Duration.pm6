use v6;
module Time::Duration;
# POD is at the end.

constant $DEBUG = False;

# ALL SUBS ARE PURE FUNCTIONS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub concise(Str $string is copy) is export {
  #print "in : $string\n";
  $string .= trans( ',' => '' ); #tr/,//d;
  $string ~~ s/<<and>>//;
  $string ~~ s:g/<<(year|day|hour|minute|second)s?>>/{ $0.substr(0,1) }/;
  $string ~~ s:g/\s*(\d+)\s*/$0/;
  return $string;
}

sub later(Int $sec, Int $prec = 2) is export {
  interval($sec, $prec, ' earlier', ' later', 'right then'); }

sub later_exact(Int $sec) is export {
  interval_exact($sec, ' earlier', ' later', 'right then'); }

sub earlier(Int $sec, Int $prec = 2) is export {
  interval($sec, $prec, ' later', ' earlier', 'right then'); }

sub earlier_exact(Int $sec) is export {
  interval_exact($sec, ' later', ' earlier', 'right then'); }

sub ago(Int $sec, Int $prec = 2) is export {
  interval($sec, $prec, ' from now', ' ago', 'right now'); }

sub ago_exact(Int $sec) is export {
  interval_exact($sec, ' from now', ' ago', 'right now'); }

sub from_now(Int $sec, Int $prec = 2) is export {
  interval($sec, $prec, ' ago', ' from now', 'right now'); }

sub from_now_exact(Int $sec) is export {
  interval_exact($sec, ' ago', ' from now', 'right now'); }

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub duration_exact(Int $span) is export {
  return '0 seconds' unless $span;
  _render('',
          _separate(abs $span));
}

sub duration(Int $span, Int $precision = 2) is export {
  return '0 seconds' unless $span;
  _render('',
          _approximate($precision,
                       _separate(abs $span)));
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub interval_exact(Int $span, Str $neg, Str $pos, Str $zero) {
  #my $span = $_[0];                     # interval, in seconds
                                         # precision is ignored
  my $direction = ($span <= -1) ?? $neg  # what a neg number gets
                !! ($span >=  1) ?? $pos  # what a pos number gets
                !! return          $zero; # what zero gets
  _render($direction,
          _separate($span));
}

sub interval(Int $span, Int $precision, Str $neg, Str $pos, Str $zero) {
  my $direction = ($span <= -1) ?? $neg  # what a neg number gets
                !! ($span >=  1) ?? $pos  # what a pos number gets
                !! return          $zero; # what zero gets
  _render($direction,
          _approximate($precision,
                       _separate($span)));
}

#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
#
# The actual figuring is below here


sub _separate($remainder is copy) {
  # Breakdown of seconds into units, starting with the most significant

  $remainder = abs $remainder;
  my $this; # scratch
  my @wheel; # retval

  # Years:
  $this = floor($remainder / (365 * 24 * 60 * 60));
  push @wheel, ['year', $this, 1_000_000_000];
  $remainder -= $this * (365 * 24 * 60 * 60);

  # Days:
  $this = floor($remainder / (24 * 60 * 60));
  push @wheel, ['day', $this, 365];
  $remainder -= $this * (24 * 60 * 60);

  # Hours:
  $this = floor($remainder / (60 * 60));
  push @wheel, ['hour', $this, 24];
  $remainder -= $this * (60 * 60);

  # Minutes:
  $this = floor($remainder / 60);
  push @wheel, ['minute', $this, 60];
  $remainder -= $this * 60;

  push @wheel, ['second', floor($remainder), 60];
  return @wheel;
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub _approximate($precision, @wheel) {
  # Now nudge the wheels into an acceptably (im)precise configuration

  {
    # Constraints for leaving this block:
    #  1) number of nonzero wheels must be <= $precision
    #  2) no wheels can be improperly expressed (like having "60" for mins)

    my $nonzero_count = 0;
    my $improperly_expressed;

    $DEBUG and say "approximate wheel: ", @wheel.perl;
    loop (my $i = 0; $i < @wheel.elems; $i++) {
      my $this = @wheel[$i];
      next if $this.[1] == 0; # Zeros require no attention.
      ++$nonzero_count;
      next if $i == 0; # the years wheel is never improper or over any limit; skip

      if $nonzero_count > $precision {
        # This is one nonzero wheel too many!
        $DEBUG and print '', $this.[0], " is one nonzero too many! ($nonzero_count > $precision)\n";

        # Incr previous wheel if we're big enough:
        if $this.[1] >= ($this.[*-1] / 2) {
          $DEBUG and printf "incrementing %s from %s to %s\n",
           @wheel[$i-1][0], @wheel[$i-1][1], 1 + @wheel[$i-1][1], ;
          ++@wheel[$i-1][1];
        }

        # Reset this and subsequent wheels to 0:
        loop (my $j = $i; $j < @wheel.elems; $j++) { @wheel[$j][1] = 0 }
        return _approximate($precision, @wheel);
      } elsif ($this.[1] >= $this.[*-1]) {
        # It's an improperly expressed wheel.  (Like "60" on the mins wheel)
        $improperly_expressed = $i;
        $DEBUG and print '', $this.[0], ' (', $this.[1],
           ") is improper!\n";
      }
    }

    if (defined $improperly_expressed) {
      # Only fix the least-significant improperly expressed wheel (at a time).
      $DEBUG and printf "incrementing %s from %s to %s\n",
       @wheel[$improperly_expressed-1][0], @wheel[$improperly_expressed-1][1],
        1 + @wheel[$improperly_expressed-1][1], ;
      ++@wheel[ $improperly_expressed - 1][1];
      @wheel[ $improperly_expressed][1] = 0;
      # We never have a "150" in the minutes slot -- if it's improper,
      #  it's only by having been rounded up to the limit.
      return _approximate($precision, @wheel);
    }

    # Otherwise there's not too many nonzero wheels, and there's no
    #  improperly expressed wheels, so fall thru...
  }

  return @wheel;
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub _render(Str $direction, @approximate, @separate?) {
    # Make it into English

    my @p = @approximate.list, @separate.list;

    my @wheel = map
    {;
        (  $_.[1] == 0) ?? ()  # zero wheels
            !! ($_.[1] == 1) ?? "{$_.[1]} {$_.[0]}"  # singular
            !!                  "{$_.[1]} {$_.[0]}s" # plural
    }, @p;

    return "just now" unless @wheel; # sanity
    
    @wheel[*-1] ~= $direction;
    return @wheel[0] if @wheel.elems == 1;
    return "@wheel[0] and @wheel[1]" if @wheel.elems == 2;

    @wheel[*-1] = "and @wheel[*-1]";
    return join q{, }, @wheel;
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#__END__
#
#so "1y 0d 1h 50m 50s", N=3, so you round at minutes to "1y 0d 1h 51m 0s",
##That's okay, so fall thru.
#
#so "1y 1d 0h 59m 50s", N=3, so you round at minutes to "1y 1d 0h 60m 0s",
#but that's not improperly expressed, so you loop around and get
#"1y 1d 1h 0m 0s", which is short enough, and is properly expressed.
=begin pod

=head1 NAME

Time::Duration - rounded or exact English expression of durations

=head1 SYNOPSIS

Example use in a program that ends by noting its runtime:

  my $start_time = time();
  use Time::Duration;

  # then things that take all that time, and then ends:
  print "Runtime ", duration(time() - $start_time), ".\n";

Example use in a program that reports age of a file:

    use Time::Duration;
    my $file = 'that_file';
    my $age = SomeModule::get_modtime($file);
    print "$file was modified ", ago($age);

=head1 DESCRIPTION

This module provides functions for expressing durations in rounded or exact
terms.


In the first example in the Synopsis, using duration($interval_seconds):

If the C<time() - $start_time> is 3 seconds, this prints
"Runtime: B<3 seconds>.".  If it's 0 seconds, it's "Runtime: B<0 seconds>.".
If it's 1 second, it's "Runtime: B<1 second>.".  If it's 125 seconds, you
get "Runtime: B<2 minutes and 5 seconds>.".  If it's 3820 seconds (which
is exactly 1h, 3m, 40s), you get it rounded to fit within two expressed
units: "Runtime: B<1 hour and 4 minutes>.".  Using duration_exact instead
would return "Runtime: B<1 hour, 3 minutes, and 40 seconds>".

In the second example in the Synopsis, using ago($interval_seconds):

If the $age is 3 seconds, this prints
"I<file> was modified B<3 seconds ago>".  If it's 0 seconds, it's
"I<file> was modified B<just now>", as a special case.  If it's 1 second,
it's "from B<1 second ago>".  If it's 125 seconds, you get "I<file> was
modified B<2 minutes and 5 seconds ago>".  If it's 3820 seconds (which
is exactly 1h, 3m, 40s), you get it rounded to fit within two expressed
units: "I<file> was modified B<1 hour and 4 minutes ago>".
Using ago_exact instead
would return "I<file> was modified B<1 hour, 3 minutes, and 40 seconds
ago>".  And if the file's
modtime is, surprisingly, three seconds into the future, $age is -3,
and you'll get the equally and appropriately surprising
"I<file> was modified B<3 seconds from now>."


=head1 FUNCTIONS

This module provides all the following functions, which are all exported
by default when you call C<use Time::Duration;>.


=over

=item duration($seconds)

=item duration($seconds, $precision)

Returns English text expressing the approximate time duration
of abs($seconds), with at most S<C<$precision || 2>> expressed units.
(That is, duration($seconds) is the same as duration($seconds,2).)

For example, duration(120) or duration(-120) is "2 minutes".  And
duration(0) is "0 seconds".

The precision figure means that no more than that many units will
be used in expressing the time duration.  For example,
31,629,659 seconds is a duration of I<exactly>
1 year, 1 day, 2 hours, and 59 seconds (assuming 1 year = exactly
365 days, as we do assume in this module).  However, if you wanted
an approximation of this to at most two expressed (i.e., nonzero) units, it
would round it and truncate it to "1 year and 1 day".  Max of 3 expressed
units would get you "1 year, 1 day, and 2 hours".  Max of 4 expressed
units would get you "1 year, 1 day, 2 hours, and 59 seconds",
which happens to be exactly true.  Max of 5 (or more) expressed units
would get you the same, since there are only four nonzero units possible
in for that duration.

=item duration_exact($seconds)

Same as duration($seconds), except that the returned value is an exact
(unrounded) expression of $seconds.  For example, duration_exact(31629659)
returns "1 year, 1 day, 2 hours, and 59 seconds later",
which is I<exactly> true.


=item ago($seconds)

=item ago($seconds, $precision)

For a positive value of seconds, this prints the same as
C<duration($seconds, [$precision]) . S<' ago'>>.  For example,
ago(120) is "2 minutes ago".  For a negative value of seconds,
this prints the same as
C<duration($seconds, [$precision]) . S<' from now'>>.  For example,
ago(-120) is "2 minutes from now".  As a special case, ago(0)
returns "right now".

=item ago_exact($seconds)

Same as ago($seconds), except that the returned value is an exact
(unrounded) expression of $seconds.


=item from_now($seconds)

=item from_now($seconds, $precision)

=item from_now_exact($seconds)

The same as ago(-$seconds), ago(-$seconds, $precision),
ago_exact(-$seconds).  For example, from_now(120) is "2 minutes from now".


=item later($seconds)

=item later($seconds, $precision)

For a positive value of seconds, this prints the same as
C<duration($seconds, [$precision]) . S<' later'>>.  For example,
ago(120) is "2 minutes later".  For a negative value of seconds,
this prints the same as
C<duration($seconds, [$precision]) . S<' earlier'>>.  For example,
later(-120) is "2 minutes earlier".  As a special case, later(0)
returns "right then".

=item later_exact($seconds)

Same as later($seconds), except that the returned value is an exact
(unrounded) expression of $seconds.

=item earlier($seconds)

=item earlier($seconds, $precision)

=item earlier_exact($seconds)

The same as later(-$seconds), later(-$seconds, $precision),
later_exact(-$seconds).  For example, earlier(120) is "2 minutes earlier".


=item concise( I<function(> ... ) )

Concise takes the string output of one of the above functions and makes
it more concise.  For example,
C<< ago(4567) >> returns "1 hour and 16 minutes ago", but
C<< concise(ago(4567)) >> returns "1h16m ago".

=back



=head1 I18N/L10N NOTES

Little of the internals of this module are English-specific.  See source
and/or contact me if you're interested in making a localized version
for some other language than English.



=head1 BACKSTORY

I wrote the basic C<ago()> function for use in Infobot
(C<http://www.infobot.org>), because I was tired of this sort of
response from the Purl Infobot:

  me> Purl, seen Woozle?
  <Purl> Woozle was last seen on #perl 20 days, 7 hours, 32 minutes
  and 40 seconds ago, saying: Wuzzle!

I figured if it was 20 days ago, I don't care about the seconds.  So
once I had written C<ago()>, I abstracted the code a bit and got
all the other functions.


=head1 CAVEAT

This module calls a durational "year" an interval of exactly 365
days of exactly 24 hours each, with no provision for leap years or
monkey business with 23/25 hour days (much less leap seconds!).  But
since the main work of this module is approximation, that shouldn't
be a great problem for most purposes.


=head1 SEE ALSO

L<Date::Interval|Date::Interval>, which is similarly named, but does
something rather different.

I<Star Trek: The Next Generation> (1987-1994), where the character
Data would express time durations like
"1 year, 20 days, 22 hours, 59 minutes, and 35 seconds"
instead of rounding to "1 year and 21 days".  This is because no-one
ever told him to use Time::Duration.



=head1 COPYRIGHT AND DISCLAIMER

Copyright 2006, Sean M. Burke C<sburke@cpan.org>, 
Copyright 2013, Dagur Valberg Johannsson, 
all rights reserved.  This program is free software; you can redistribute it
and/or modify it under the same terms as Perl 5 itself.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=head1 AUTHOR

Original Author: Sean M. Burke, `sburke@cpan.org'
Perl 5 Maintainer: Avi Finkel, `avi@finkel.org'
Ported and maintained in Perl 6 by: Dagur Valberg Johannsson

=end pod


