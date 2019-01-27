use v6.c;

module Acme::Don't:ver<0.0.2>:auth<cpan:ELIZABETH> {
    sub don't(& --> Nil) is export { }
}

=begin pod

=head1 NAME

Acme::Don't - The opposite of do

=head1 SYNOPSIS

    use Acme::Don't;

    don't { print "This won't be printed\n" };    # NO-OP

=head1 DESCRIPTION

The Acme::Don't module provides a C<don't> command, which is the 
opposite of Perl's built-in C<do>.

It is used exactly like the C<do BLOCK> function except that,
instead of executing the block it controls, it...well...doesn't.

Regardless of the contents of the block, C<don't> returns C<undef>.

You can even write:

    don't {
        # code here
    } while condition();

And, yes, in strict analogy to the semantics of Perl's magical
C<do...while>, the C<don't...while> block is I<unconditionally>
not done once before the test. ;-)

Note that the code in the C<don't> block must be syntactically valid
Perl.  This is an important feature: you get the accelerated
performance of not actually executing the code, without sacrificing
the security of compile-time syntax checking.

=head1 LIMITATIONS

=head2 No opposite

Doesn't (yet) implement the opposite of C<do STRING>. 
The current workaround is to use:

    don't {"filename"};

=head2 Double don'ts

The construct:

    don't { don't { ... } }

isn't (yet) equivalent to:

    do { ... }

because the outer C<don't> prevents the inner C<don't> from being executed,
before the inner C<don't> gets the chance to discover that it actually
I<should> execute.

This is an issue of semantics. C<don't...> doesn't mean C<do the opposite of...>; it means C<do nothing with...>.

In other words, doin nothing about doing nothing does...nothing.

=head2 Unless not

You can't (yet) use a:

    don't { ... } unless condition();

as a substitute for:

    do { ... } if condition();

Again, it's an issue of semantics. C<don't...unless...> doesn't mean C<do the opposite of...if...>; it means C<do nothing with...if not...>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Acme-don-t . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Original author: Damian Conway.  Re-imagined from Perl 5 as part of the CPAN
Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
