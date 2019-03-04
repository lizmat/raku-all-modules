use v6;

use Cofra::Logger;

unit class Cofra::Logger::Screen does Cofra::Logger;

has IO::Handle $.handle = $*ERR;

method log-to-screen($level, @msg) {
    $.handle.say: "[$level] @msg.map(*.gist).join('')";
}

method is-logging-critical(--> Bool:D) { True }
method log-critical(*@msg) { self.log-to-screen('critical', @msg) }

method is-logging-error(--> Bool:D) { True }
method log-error(*@msg) { self.log-to-screen('error', @msg) }

method is-logging-warn(--> Bool:D) { True }
method log-warn(*@msg) { self.log-to-screen('warn', @msg) }

method is-logging-info(--> Bool:D) { True }
method log-info(*@msg) { self.log-to-screen('info', @msg) }

method is-logging-debug(--> Bool:D) { True }
method log-debug(*@msg) { self.log-to-screen('debug', @msg) }

=begin pod

=head1 NAME

Cofra::Logger::Screen - it writes to the screen when you want to log

=head1 SYNOPSIS

    use Cofra::Logger::Screen;

    my Cofra::Logger::Screen $logger .= new;

    $logger.log-error("bad stuff");
    $logger.log-info("boring stuff");
    $logger.log-debug("loud and obnoxious stuff");

=head1 DESCRIPTION

This implements the interface describe by L<Cofra::Logger> to write logs to a file handle, standard error by default.

=head1 METHODS

=head2 method handle

    has IO::Handle $.handle = $*ERR;

Defines the handle to write logs into. It defaults to C<$*ERR> (in case that wasn't obvious from the code snippet).

=end pod
