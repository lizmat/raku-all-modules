use v6;

use LibraryMake;

my sub library {
    my $so = get-vars('')<SO>;
    return "%?RESOURCES{"libdsthelper$so"}";
}

module DateTime::DST:ver<0.2>:auth<github:zostay> {
    use NativeCall;
    my sub is_dst(int64) returns int64 is native(&library) { * }

    multi is-dst(Instant $time) returns Bool is export {
        my ($posix, $leap-sec) = $time.to-posix;
        callwith($posix);
    }

    multi is-dst(DateTime $time) returns Bool is export {
        callwith($time.posix);
    }

    multi is-dst(Int() $posix) returns Bool is export {
        ?is_dst($posix);
    }
}

=begin pod

=NAME DateTime::DST - make localtime[8] available as is-dst()

=begin SYNOPSIS

    use DateTime::DST;

    my $non-dst = DateTime.new(:2016year, :1month, :15day, :0hour, :0minute, :0second);
    my $dst     = DateTime.new(:2016year, :6month, :15day, :0hour, :0minute, :0second);

    say is-dst($non-dst);         # False
    say is-dst($non-dst.Instant); # False
    say is-dst($non-dst.posix);   # False

    say is-dst($dst);             # True
    say is-dst($dst.Instant);     # True
    say is-dst($dst.posix);       # True

=end SYNOPSIS

=head1 DESCRIPTION

This is nothing too fancy, just exports a function named C<is-dst> which can be used to test for Daylight Savings Time from a DateTime object, an Int (expecting seconds since the start of the POSIX time_t epoch), or an Instant.

=head1 FUNCTIONS

=head2 is-dst

    multi is-dst(Instant $time) returns Bool
    multi is-dst(DateTime $time) returns Bool
    multi is-dst(Int $time) returns Bool

Returns C<True> if the C-standard library C<localtime> function returns a true value for the DST flag or C<False> otherwise. This is basically the same as C<localtime($time)[8]> in Perl 5.

=head1 AUTHOR

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Andrew Sterling Hanenkamp.

This software is made available under the same terms as Perl 6 itself.

=end pod
