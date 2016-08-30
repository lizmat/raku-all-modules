unit class Shell::Capture:ver<0.2.0>:auth<github:ppentchev>;

use v6.c;

has Int $.exitcode;
has Str @.lines;

method capture(*@cmd, Str :$nl, Str :$enc) returns Shell::Capture:D
{
	my Proc:D $p = run @cmd, :out, |(:$nl with $nl), |(:$enc with $enc);
	my Str:D @res = $p.out.lines;
	my $exit = $p.out.close;
	return Shell::Capture.new(:exitcode($p.exitcode), :lines(@res));
}

method capture-check(List :$accept = (0,), Block :$fail, Str :$message, *@cmd, Str :$nl, Str :$enc) returns Shell::Capture:D
{
	my Shell::Capture:D $r = self.capture(|@cmd, |(:$nl with $nl), |(:$enc with $enc));
	if not $r.exitcode (elem) $accept {
		if defined $fail {
			$fail($r, @cmd);
		} else {
			note $message // '"' ~ @cmd ~ '" failed';
			exit 1
		}
	}
	return $r;
}

=begin pod

=head1 NAME

Shell::Capture - capture a command's output and exit code

=head1 SYNOPSIS

=begin code
    use Shell::Capture;

    my Shell::Capture $c .= capture('id', '-u', '-n');
    if $c.exitcode != 0 {
        die "Could not execute id -u -n\n";
    } elsif $c.lines.elems != 1 {
        die "id -u -n returned something unexpected:\n" ~ $c.lines.join("\n") ~ "\n";
    }
    say "Got my username: " ~ $c.lines[0];

    sub fail($r, @cmd) {
        die "fail with exit code $r.exitcode() and $r.lines().elems() " ~
            "line(s) of output and cmd " ~ @cmd;
    }

    $c .= capture-check(:accept(0, 3), 'sh', '-c', 'date');
    say "The current date is $c.lines()[0]" if $c.exitcode == 0;

    $c .= capture-check(:accept(0, 3), 'sh', '-c', 'date; exit 3');
    say "The current date is $c.lines()[0]" if $c.exitcode == 3;

    $c .= capture-check(:accept(0, 3), :&fail, 'sh', '-c', 'date; exit 1');
    say 'not reached, fail() dies';

    $c .= capture-check('git', 'ls-files', '-z', :nl("\0"));
    say 'Got some unquoted filenames from Git:';
    $c.lines>>.say;

    $c .= capture-check('env', 'LANG=fr_FR.ISO-8859-1', 'date', :enc('ISO-8859-1'));
=end code

=head1 DESCRIPTION

This class provides two methods to execute an external command, capture
its output and exit code, and, in C<capture-check()>, raise an error on
unexpected exit code values.

=head1 FIELDS

=begin item1
exitcode

    Int:D $.exitcode

The exit code of the executed external command.
=end item1

=begin item1
lines

    Str:D @.lines

The output of the external command split into lines with the newline
terminator removed.
=end item1

=head1 METHODS

=begin item1
method capture()

    method capture(*@cmd, Str :$enc, Str :$nl)

Execute the specified command in the same way as C<run()> would, then
create a new C<Shell::Capture> object with its C<exitcode> and C<lines>
members set respectively to the exit code of the command and its output
split into lines, as described above.

The C<$enc> and C<$nl> parameters, if supplied, are passed directly
to C<run()>, allowing the caller to specify the encoding of the data
output by the external program and the character (or string) used to
delimit lines in the output.  See the C<Proc.new()> documentation for
more information.
=end item1

=begin item1
method capture-check()

    method capture-check(:$accept, :$fail, Str :$enc, Str :$nl, *@cmd)

Execute the specified command and create a C<Shell::Capture> object in
the same way as C<capture()>, then check the exit code against the
C<$accept> list (default: only 0).  If the exit code is on the list,
return the C<Shell::Capture> object to the caller.

If the exit code is not on the list and there is no C<$fail> handler
specified, output an error message to the standard error stream and
terminate the program.  If a fail handler is specified, invoke it with
two arguments: the C<Shell::Capture> object for further examination and
the command executed; if the fail handler returns, C<capture-check()>
will return the C<Shell::Capture> object to its caller (useful for
writing tests).

The C<$enc> and C<$nl> parameters, if specified, are passed directly
to C<run()> just as in C<capture()>.
=end item1

=head1 AUTHOR

Peter Pentchev <L<roam@ringlet.net|mailto:roam@ringlet.net>>

=head1 COPYRIGHT

Copyright (C) 2016  Peter Pentchev

=head1 LICENSE

The Shell::Capture module is distributed under the terms of
the Artistic License 2.0.  For more details, see the full text of
the license in the file LICENSE in the source distribution.

=end pod
