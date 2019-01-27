use v6;

use HTTP::Supply::Request;

unit class HTTP::Request::Supply is HTTP::Supply::Request;

=begin pod

=NAME HTTP::Request::Supply - DEPRECATED Use HTTP::Supply::Request instead

=begin SYNOPSIS

    # You should rename all existing code to use HTTP::Supply::Request.
    # Otherwise, the interface is the same.

=end SYNOPSIS

=begin DESCRIPTION

This was the original namespace for this class. It is now deprecated. All
functionality has been moved to L<HTTP::Supply::Request>.

=end DESCRIPTION

=head1 AUTHOR

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Sterling Hanenkamp.

This software is licensed under the same terms as Perl 6.

=end pod

method parse-http(|c) is DEPRECATED {
    self.HTTP::Supply::Request::parse-http(|c);
}
