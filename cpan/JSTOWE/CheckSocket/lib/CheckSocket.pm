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

This exports a single function that returns a C<Bool> to indicate whether
something is listening on the specified TCP port:

=head2 check-socket

    sub check-socket(Int $port, Str $host = "localhost" --> Bool ) 

This attempts to connect to the socket specified by $port and $host and
if succesfull will return C<True> otherwise it will catch any exception
caused by the attempt and return C<False>.   It makes no attempt to
report any reason for the failure so means it is probably not useful
for network diagnosis, it's primary intent is for tests to be able to
determine whether a particular network service is present to test against.

=head2 wait-socket

    sub wait-socket( Int $port, Str $host = "localhost", Int $wait = 1, Int $tries = 3 --> Bool )

This attempts to connects to the socket specified by $port and $host
retrying a maximum of $tires times every $wait second and then returning
a Bool to indicate whether the server is available as C<check-socket>.
This may be useful when you want to start a server asynchronously in some
test code and wait for it to be ready to use.

=end pod

module CheckSocket:ver<0.0.6>:auth<github:jonathanstowe>:api<1.0> {
    sub check-socket(Int $port, Str $host = "localhost" --> Bool ) is export {
        my Bool $rc = True;
        try {
            my $msock = IO::Socket::INET.new(:$host, :$port);
            CATCH {
                default {
                    $rc = False;
                }
            }
        }
        $rc;
    }

    sub wait-socket( Int $port, Str $host = "localhost", Int $wait = 1, Int $tries = 3 --> Bool ) is export {
        my Int $count = $tries;

        while !check-socket($port, $host ) && $count-- {
            sleep $wait
        }
        check-socket($port, $host);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
