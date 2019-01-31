use v6;

=begin pod

=head1 NAME

Lumberjack::Dispatcher::Supply - Dispatch Lumberjack messages to a Supply.

=head1 SYNOPSIS

=begin code

use Lumberjack;
use Lumberjack::Dispatcher::Supply;

my $dispatcher = Lumberjack::Dispatcher::Supply.new;

$dispatcher.tap(-> $m { # do something with message });

Lumberjack.dispatchers.append: $dispatcher;

=end code

=head1 DESCRIPTION

This is a very simple dispatcher implementation that dispatches the
Lumberjack messages to a C<Supply>, this is provided for the convenience
of the C<Lumberjack::Application::WebSocket>, in conveying the messages
from the dispatch mechanism to the client connections, but may have a
more general use.

=head1 METHODS

=head2 method new

    method new()

This takes the C<classes> and C<levels> parameters that are provided
for by C<Lumberjack::Provider> but has no other useful parameters.

=head2 method tap

This is a delegate from the underlying Supply that is provided for
convenience.

=head2 attribute Supply

This is the C<Supply> to which the messages will be emitted.

=end pod

use Lumberjack;

class Lumberjack::Dispatcher::Supply does Lumberjack::Dispatcher {
    has Supplier $!supplier = Supplier.new;
    has Supply   $.Supply;

    method Supply( --> Supply ) handles <tap> {
        if not $!Supply.defined {
            $!Supply = $!supplier.Supply;
        }
    }

    method log(Lumberjack::Message $message) {
        $!supplier.emit($message);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
