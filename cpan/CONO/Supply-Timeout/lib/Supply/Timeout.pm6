use v6;

class X::Supply::Timeout is Exception {
    method message { "Timed out" }
}

class Supply::Timeout:ver<0.0.1>:auth<cono "q@cono.org.ua"> {
    has Supply $.supply;
    has $.timeout;

    method new($supply = Supply.interval(0.1), $timeout = 15) {
        self.bless(:$supply, :$timeout);
    }

    method Supply(--> Supply) {
        supply {
            my $last = now;
            whenever $!supply {
                $last = now;
                emit $_
            }
            whenever Supply.interval(0.1) {
                if now - $last > $!timeout {
                    X::Supply::Timeout.new.throw;
                }
            }
        }
    }
}

=begin pod

=head1 NAME

Supply::Timeout - Supply wrapper which can terminate by timeout.

=head1 SYNOPSIS

=begin code

use Supply::Timeout;

react {
    whenever IO::Socket::Async.listen('0.0.0.0', 3333) -> $conn {
        whenever Supply::Timeout.new($conn.Supply.lines, 4) -> $line {
            $conn.print("$line\n");
            QUIT {
                when X::Supply::Timeout {
                    $conn.print("TIMEOUT\n");
                    $conn.close;
                }
            }
        }
    }
    whenever signal(SIGINT) { done(); exit; }
}

=end code

=head1 DESCRIPTION

Supply::Timeout can surround your Supply by another one with ability to
interrupt in case timeout happend.

=head2 METHODS

=head3 new($supply = Supply.interval(0.1), $timeout = 15)

Default constructor

=head3 supply

Accessor to the internal Supply instance.

=head3 timeout

Accessor to the timeout value.

=head3 Supply

Method which produce new Supply with timeout functionality.

=head1 AUTHOR

cono <q@cono.org.ua>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 cono

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
