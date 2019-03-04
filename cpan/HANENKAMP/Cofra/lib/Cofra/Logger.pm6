use v6;

unit role Cofra::Logger;

method is-logging-critical(--> Bool:D) { ... }
method log-critical(*@msg) { ... }

method is-logging-error(--> Bool:D) { ... }
method log-error(*@msg) { ... }

method is-logging-warn(--> Bool:D) { ... }
method log-warn(*@msg) { ... }

method is-logging-info(--> Bool:D) { ... }
method log-info(*@msg) { ... }

method is-logging-debug(--> Bool:D) { ... }
method log-debug(*@msg) { ... }

=begin pod

=head1 NAME

Cofra::Logger - the global logging interface

=head1 SYNOPSIS

    use Cofra::Logger;

    unit class MyApp::Logger does Cofra::Logger;

    method is-logging-critical(--> Bool:D) { True }
    method is-logging-error(--> Bool:D) { True }
    method is-logging-warn(--> Bool:D) { True }
    method is-logging-info(--> Bool:D) { True }
    method is-logging-debug(--> Bool:D) { True }

    method log-critical(*@msg) { $*ERR.say: @msg }
    method log-error(*@msg) { $*ERR.say: @msg }
    method log-warn(*@msg) { $*ERR.say: @msg }
    method log-info(*@msg) { $*ERR.say: @msg }
    method log-debug(*@msg) { $*ERR.say: @msg }

=head1 DESCRIPTION

As of now, this defines nothing of value except the interface the logger must
provide. That will probably change in the future so that you don't have to write
up all that junk in the L<#SYNOPSIS>.

My fingers got tired just documenting it. Let's never do that again... but
that's all there is for now.

=end pod
