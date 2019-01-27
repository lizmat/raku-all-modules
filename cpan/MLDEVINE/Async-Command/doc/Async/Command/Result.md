Description
===========

`Async::Command::Result` encapsulates the attributes of running a command.

Attributes
----------

_command_

The executed command that produced the result.

_exit-code_

The exit code returned from the command after completion.

_stderr-results_

The STDERR stream from the command.

_stdout-results_

The STDOUT stream from the command.

_time-out_

The timer that constrained the command's execution opportunity.

_timed-out_

A flag that indicates whether or not the command completed
within the prescribed time interval. If timed-out is true,
execution was likely aborted.

_unique-id_

An arbitrary identifier that is typically used to track
the command from the original caller's perspective.

Synopsis
========

    use Async::Command::Result;

    my $result = Async::Command::Result.new(
        :@command,
        :$exit-code,
        :$stderr-results,
        :$stdout-results,
        :$time-out,
        :$timed-out,
        :$unique-id,
    );

    say $result.command;
    say $result.exit-code;
    say $result.stderr-results;
    say $result.stdout-results;
    say $result.time-out;
    say $result.timed-out;
    say $result.unique-id;

See Also
========
Async::Command

Async::Command::Multi
