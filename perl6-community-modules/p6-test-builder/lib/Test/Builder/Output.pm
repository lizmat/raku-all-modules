# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

=begin pod

=head1 NAME

Test::Builder::Output - handles output operations for Test::Builder objects

=head1 DESCRIPTION

The purpose of the C<Test::Builder::Output> class is to manage all output
operations for C<Test::Builder> objects. It is generally used for reporting
test results and displaying diagnostics for test failures.

B<NOTE:> The C<Test::Builder::Output> class should not be used directly.
It is only meant to be used internally.

=head1 USE

=head2 Public Attributes

=over 4

=item I<$.stdout>

Specifies the filehandle that should be used for normal output such as
reporting individual test results and the final pass/fail status.

Defaults to C<$*OUT>.

=item I<$.stderr>

Specifies the filehandle that should be used for diagnostic messages such as
test failures and other fatal errors.

Defaults to C<$*ERR>.

=back

=head2 Object Initialization

=over 4

=item B<new()>

Returns a new C<Test::Builder::Output> instance.

=back

=head2 Public Methods

=over 4

=item B<write(Str $msg)>

Writes the string given in C<$msg> to the filehandle specified by C<$.stdout>.

The C<write()> method is generally used for normal output such as reporting
test results.

=item B<diag(Str $msg)>

Writes the string given in C<$msg> to the filehandle specified by C<$.stderr>.

The diagnostic messages displayed by C<diag()> are distinct from other output
in that they are always prefixed with an octothorpe (C<#>).

=back

=head1 SEE ALSO

L<http://testanything.org>

=head1 ACKNOWLEDGEMENTS

C<Test::Builder> was largely inspired by chromatic's work on the old
C<Test::Builder> module for Pugs.

Additionally, C<Test::Builder> is based on the Perl 5 module of the same name
also written by chromatic <chromatic@wgz.org> and Michael G. Schwern
<schwern@pobox.com>.

=head1 COPYRIGHT

Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit 
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.

=end pod

#= Handles output operations for Test::Builder objects
class Test::Builder::Output;
    has $!stdout;    #= Filehandle used by write()
    has $!stderr;    #= Filehandle used by diag()

    # XXX Can I just set default attribute values and remove BUILD()?
    submethod BUILD($!stdout = $*OUT, $!stderr = $*ERR) { }

    #= Displays output to filehandle set by $.stdout
    method write(Str $msg is copy) {
        #$msg ~~ s:g/\n <!before \#>/\n \# <space>/;
        $!stdout.say($msg);
    }

    #= Displays diagnostic message to filehandle set by $.stderr
    method diag(Str $msg is copy) {
        # XXX Uncomment lines when Rakudo supports negative lookahead assertions
        #$msg ~~ s/^ <!before \#>/\# <space>/;
        #$msg ~~ s:g/\n <!before \#>/\n \# <space>/;

        $msg ~~ s/^/\x23 \x20/;
        $msg.=subst("\x0a", "\x0a\x23\x20");

        $!stderr.say($msg);
    }

# vim: ft=perl6

