use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use DateTime::Monotonic;

module Net::BGP::Time:ver<0.0.8>:auth<cpan:JMASLAK> {
    sub monotonic-seconds(-->Numeric) is export {
        return DateTime::Monotonic::monotonic-seconds;
    }

    sub monotonic-whole-seconds(-->Int) is export {
        return DateTime::Monotonic::monotonic-whole-seconds;
    }
};

=begin pod

=head NAME

Net::BGP::Time - Time utilities

=head1 SYNOPSIS

  use Net::BGP::Time;
  say "Seconds since timer initialization: { monotonic-seconds }";
  say "Whole Seconds since timer initialization: { monotonic-whole-seconds }";

=head1 SUBROUTINES

=head2 monotonic-seconds(-->Int) is export

Returns number of seconds since module was loaded, including fractional
seconds.

=head2 monotonic-whole-seconds(-->Int) is export

Returns number of seconds since module was loaded, in whole numbers of seconds.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0

=end pod

