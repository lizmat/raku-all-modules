use v6;

=begin pod

=head1 NAME

HTTP::Server::Ogre

=head1 SYNOPSIS

  use HTTP::Server::Ogre;

=head1 DESCRIPTION

HTTP::Server::Ogre is not tiny nor easy to handle. He is rather a stupid ogre that handles parallel http requests

=head1 AUTHOR

Martin Barth <martin@senfdax.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Martin Barth

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

use HTTP::Server::Ogre::Http1Protocol;

class HTTP::Server::Ogre:ver<0.0.2> {
    has Str  $.host is required;
    has Int  $.port is required;
    has      $.app  is required;
    has Bool $.tls-mode  = False;
    has      $.http-mode;
    has      %.tls-config = ();

    my %protocols = (
        '1.1' => HTTP::Server::Ogre::Http1Protocol.new;
        # '2'   => HTTP::Server::Ogre::Http2Protocol.new;
    );

    method run() {
        my $http-mode;
        my $listener;

        if $.tls-mode {
            require IO::Socket::Async::SSL;
            sub supports-alpn { IO::Socket::Async::SSL.supports-alpn };
            if $!http-mode == <2> {
                # serve http 2 only
                die 'HTTP/2 is requested but ALPN is not supported' unless supports-alpn;
                %.tls-config<alpn> = <h2>;
                $http-mode = <2>;
            } elsif $!http-mode eqv <1.1 2>|<2 1.1> {
                # client can choose http version
                die 'HTTP/2 is requested but ALPN is not supported' unless supports-alpn;
                %.tls-config<alpn> = <h2 http/1.1>;
                $http-mode = <client>;
            } elsif $!http-mode == <1.1> {
                # server http 1.1 only
                $http-mode = <1.1>;
            } elsif !defined $!http-mode {
                if supports-alpn() {
                    # client can choose http version
                    %.tls-config<alpn> = <h2 http/1.1>;
                    $http-mode = <client>;
                } else {
                    # serve http 1.1 only
                    $http-mode = <1.1>;
                }
            } else {
                die 'Incorrect http mode requested. pass <1.1>, <2> or <2 1.1>';
            }
            $listener = IO::Socket::Async::SSL.listen($.host, $.port, |%!tls-config);
        } else {
            # serve http 1.1 only
            $listener = IO::Socket::Async.listen($.host, $.port);
            $http-mode = <1.1>;
        }

        react {
            whenever $listener -> $conn {
                if $http-mode eq <client> {
                    $http-mode = $conn.alpn-result ?? <2> !! <1.1>;
                }

                my $proto = %protocols{$http-mode};
                my $envs  = $proto.read-from($conn);

                whenever $envs -> %env {
                    my $promise = $.app.(%env);
                    whenever $promise -> $result {
                        $proto.write-to($conn, $result);
                    }
                }
            }
        }
    }
}
