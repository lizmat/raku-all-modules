use v6;

unit module HTTP::Supply:ver<0.3.5>:auth<github:zostay>;

=begin pod

=NAME HTTP::Supply - modern HTTP/1.x message parser

=begin SYNOPSIS

    use HTTP::Supply::Request;

    react {
        whenever IO::Socket::Async.listen('localhost', 8080) -> $conn {
            my $envs = HTTP::Supply::Request.parse-http($conn);
            whenever $envs -> %env {
                my $res := await app(%env);
                send-response($conn, $res);
            }
        }
    }

    use HTTP::Supply::Response;

    react {
        whenever IO::Socket::Async.connect('localhost', 8080) -> $conn {
            send-request($conn);

            whenever HTTP::Supply::Response.parse-http($conn) -> $res {
                handle-response($res);
                done unless send-request($conn);
            }
        }
    }

=end SYNOPSIS

=begin DESCRIPTION

B<EXPERIMENTAL:> The API for these modules is experimental and may change.

This project provides asynchronous parsers for parsing HTTP request or response pipelines. As of this writing only HTTP/1.x is supported, but I hope to add HTTP/2 and HTTP/3 support as time allows.

=end DESCRIPTION

=head1 AUTHOR

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Sterling Hanenkamp.

This software is licensed under the same terms as Perl 6.

=end pod

class GLOBAL::X::HTTP::Supply is Exception {
    method message() { "Unknown HTTP error" }
}

class GLOBAL::X::HTTP::Supply::UnsupportedProtocol is X::HTTP::Supply {
    method message() { "HTTP version is not supported." }
}

class GLOBAL::X::HTTP::Supply::BadMessage is X::HTTP::Supply {
    has $.reason is required;
    method message() { $!reason }
}

