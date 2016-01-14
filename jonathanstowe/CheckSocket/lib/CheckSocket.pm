use v6;

=begin pod

=head1 NAME

CheckSocket - test if a socket is listening

=head1 SYNOPSIS

=begin code

     use Test;
     use CheckSocket;

     if not check-socket(80, "localhost") {
        skip-all "no web server";
        exit;
     }

     ...

=end code

=head1 DESCRIPTION

This exports a single function that returns a C<Bool> to indicate whether something is listening
on the specified TCP port:

=head2 check-socket

    sub check-socket(Int $port, Str $host = "localhost") returns Bool

This attempts to connect to the socket specified by $port and $host and if succesfull will return
C<True> otherwise it will catch any exception caused by the attempt and return C<False>.   It makes
no attempt to report any reason for the failure so means it is probably not useful for network
diagnosis, it's primary intent is for tests to be able to determine whether a particular network
service is present to test against.

=end pod

module CheckSocket:ver<v0.0.2>:auth<github:jonathanstowe> {
    sub check-socket(Int $port, Str $host = "localhost") returns Bool is export {
        my Bool $rc = True;
        try {
            my $msock = IO::Socket::INET.new(host => $host, port => $port);
            CATCH {
                default {
                    $rc = False;
                }
            }
        }
        $rc;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
