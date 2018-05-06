use v6.c;

# role to distinguish normal Perl 5 handles from normal IO::Handles
my role P5Handle { }

module P5print:ver<0.0.2>:auth<cpan:ELIZABETH> {

    # create standard Perl 5 handles and export them
    my sub term:<<STDIN>>()  is export { $*IN  but P5Handle }
    my sub term:<<STDOUT>>() is export { $*OUT but P5Handle }
    my sub term:<<STDERR>>() is export { $*ERR but P5Handle }

    # add candidates to handle P5Handle
    multi sub print(P5Handle $handle, *@_) is export {
        $handle.print(@_)
    }
    multi sub print() is default is export {
        $*OUT.print(CALLERS::<$_>)
    }
    multi sub printf(P5Handle $handle, Cool:D $format, *@_) is export {
        $handle.printf($format, @_)
    }
    multi sub say(P5Handle $handle, *@_) is export {
        $handle.say(@_)
    }
    multi sub say() is default is export {
        $*OUT.say(CALLERS::<$_>)
    }
}

=begin pod

=head1 NAME

P5print - Implement Perl 5's print() and associated built-ins

=head1 SYNOPSIS

    use P5print; # exports print, printf, say, STDIN, STDOUT, STDERR

    print STDOUT, "foo";

    printf STDERR, "%s", $bar;

    say STDERR, "foobar";      # same as "note"

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<print>, C<printf> and
C<say> builtin functions of Perl 5 as closely as possible.

=head1 PORTING CAVEATS

In Perl 6, there B<must> be a comma after the handle, as opposed to Perl 5
where the whitespace after the handle indicates indirect object syntax.

    print STDERR "whee!";   # Perl 5 way

    print STDERR, "whee!";  # Perl 6 mimicing Perl 5

Perl 6 warnings on P5-isms kick in when calling C<print> or C<say> without
any parameters or parentheses.  This warning can be circumvented by adding
C<()> to the call, so:

    print;   # will complain
    print(); # won't complain and print $_

=head1 IDIOMATIC PERL 6 WAYS

When needing to write to specific handle, it's probably easier to use the
method form.

    $handle.print("foo");
    $handle.printf("foo");
    $handle.say("foo");

If you want to do a C<say> on C<STDERR>, this is easier done with the C<note>
builtin function:

    $*ERR.say("foo");  # "foo\n" on standard error
    note "foo";        # same

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5print . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
