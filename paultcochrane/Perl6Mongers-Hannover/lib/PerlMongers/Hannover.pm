module PerlMongers::Hannover;

sub info is export {
    my $path = "$*CWD";
    my $package = $path ~ "/lib/PerlMongers/Hannover.pm";
    my $cmd = "perl6 --doc $package";
    qqx{$cmd};
}

=begin pod

=head1 NAME

PerlMongers::Hannover - Hannover Perl Mongers

=head1 VERSION

Version 0.7.6

=head1 SYNOPSIS

    use PerlMongers::Hannover;

    info.say;

=head2 Website

http://hannover.pm

=head2 IRC Channel

L<irc://irc.perl.org/#hannover.pm>

=head2 Mailing List

http://mail.pm.org/mailman/listinfo/hannover-pm

=head2 Email

L<mailto:hannover-pm@pm.org>

=head2 Meetups

Every odd calendar week Tuesday at 6pm; date and location details announced
via Twitter, email and via the web site:

http://hannover.pm/treffen

=head2 Blog

http://hannover.pm/blog

=head2 Twitter

https://twitter.com/Hannover_pm

=head2 GitHub

https://github.com/Hannover-pm

=head1 METHODS

=head2 info

Returns information about the Hannover Perl Mongers.

=head1 SUPPORT

=head2 Source Code

The code repository for this package is available at:

L<https://github.com/paultcochrane/PerlMongers-Hannover>

    git clone https://github.com/paultcochrane/PerlMongers-Hannover.git

=head1 AUTHOR

Paul Cochrane <ptc@hannover.pm>

=head1 NOTES

Inspired by Lynn Root's I<pyladies> lightning talk at EuroPython 2014 and
modeled after C<PerlMongers::Bangalore>.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Hannover Perl Mongers.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=end pod

# vim: ft=perl6
