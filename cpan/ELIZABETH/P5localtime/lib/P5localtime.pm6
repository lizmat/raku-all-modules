use v6.c;
unit module P5localtime:ver<0.0.2>:auth<cpan:ELIZABETH>;

use NativeCall;

my class TimeStruct is repr<CStruct> {
    has int32 $.tm_sec;
    has int32 $.tm_min;
    has int32 $.tm_hour;
    has int32 $.tm_mday;
    has int32 $.tm_mon;
    has int32 $.tm_year;
    has int32 $.tm_wday;
    has int32 $.tm_yday;
    has int32 $.tm_isdst;
    has long  $.tm_gmtoff;
    has Str   $.tm_zone;

    method result() {
        ($.tm_sec, $.tm_min, $.tm_hour, $.tm_mday,  $.tm_mon, $.tm_year,
         $.tm_wday,$.tm_yday,$.tm_isdst,$.tm_gmtoff,$.tm_zone)
    }
}

my sub get-localtime(int64 $ is rw --> TimeStruct)
  is native is symbol<localtime> {*}
my sub get-ctime(int64 $ is rw --> Str)
  is native is symbol<ctime> {*}
my sub get-gmtime(int64 $ is rw --> TimeStruct)
  is native is symbol<gmtime> {*}

proto sub localtime(|) is export {*}
multi sub localtime(:$scalar) { localtime(time, :$scalar) }
multi sub localtime(Int() $time, :$scalar) {
    my int64 $epoch = $time;  # must be a separate definition
    $scalar
      ?? get-ctime($epoch).chomp
      !! get-localtime($epoch).result
}

proto sub gmtime(|) is export {*}
multi sub gmtime(:$scalar) { gmtime(time, :$scalar) }
multi sub gmtime(Int() $time, :$scalar) {
    my int64 $epoch = $time;  # must be a separate definition
    if $scalar {
        $epoch -= get-localtime($epoch).tm_gmtoff;
        get-ctime($epoch).chomp
    }
    else {
        get-gmtime($epoch).result
    }
}

=begin pod

=head1 NAME

P5localtime - Implement Perl 5's localtime / gmtime built-ins

=head1 SYNOPSIS

    use P5localtime;

    #     0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    say localtime(time, :scalar);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    say gmtime(time, :scalar);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<localtime> and C<gmtime>
functions of Perl 5 as closely as possible.

=head2 PORTING CAVEATS

Since Perl 6 does not have a concept of scalar context, this must be mimiced
by passing the C<:scalar> named parameter.

The implementation actually also returns the offset in GMT in seconds as
element number 9, and the name of the timezone as element number 10, if
supported by the OS.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5localtime . Comments and
Pull Requests are welcome.

=head1 ACKNOWLEDGEMENTS

JJ Merelo, Jan-Olof Hendig, Tobias Leich, Timo Paulssen and Christoph (on
StackOverflow) for support in getting this to work.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
