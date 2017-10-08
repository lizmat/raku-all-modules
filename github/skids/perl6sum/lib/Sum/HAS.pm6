=NAME Sum::HAS - implementation of HAS digest family for Sum::

=begin SYNOPSIS
=begin code
    use Sum::HAS;

    class mySum does Sum::HAS160 does Sum::Marshal::Raw { }
    my mySum $a .= new();
    $a.finalize("abc".encode('ascii')).base(16).say;
       # 975E810488CF2A3D49838478124AFCE4B1C78804

=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.
$Sum::HAS::Doc::synopsis = $=pod[1].contents[0].contents.Str;

=begin DESCRIPTION

    Using C<Sum::HAS> defines roles for generating types of C<Sum> that
    calculate hashes according to the HAS algorithm. Note that currently
    only the HAS-160 algorothm is available, and then only when librhash
    is loadable.

    HAS sums can be computationally intense.  They also require a small
    but significant memory profile while not finalized, so care must be
    taken when huge numbers of concurrent instances are used.

    NOTE: This implementation is unaudited and is for experimental
    use only.  When audits will be performed will depend on the maturation
    of individual Perl6 implementations, and should be considered
    on an implementation-by-implementation basis.

=end DESCRIPTION

use Sum;
use Sum::Recourse;

=begin pod

=head1 ROLES

=head2 role Sum::HAS160

    The C<Sum::HAS> parametric roles are used to create a type of C<Sum>
    that calculates a HAS-160 message digest.

    There currently is no pure Perl 6 implementation for this hash
    algorithm, so the only recourses are C library bindings (currently
    just librhash.)

    When C<:recourse> is defined (the default, and currently, the only
    choice), default behavior is to use C<librhash>.

    The default precedence of C libraries may be adjusted from time
    to time to prefer the best performing implementation.  To set your
    own preferences, build your own class mixing C<Sum::Recourse>.

=end pod

role Sum::HAS160[ :$recourse where { $_ == True }
                                                  = True ] does Sum does Sum::Recourse[:recourse[:librhash<HAS-160>]] { }

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2014 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=begin REFERENCES

=item "A Description of HAS-160" (Jack Lloyd) L<http://www.randombit.net/has160.html>
=item "TTAS.KO-12.0011/R1" (Telecommunications Technology Association)

=end REFERENCES

=SEE-ALSO C<Sum::(pm3)>

