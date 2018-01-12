use v6.c;

class Scalar::Util:ver<0.0.2> {

    our sub blessed(\a) is export(:SUPPORTED) {
        use nqp;
        nqp::isconcrete(nqp::decont(a)) ?? a.^name !! Nil
    }
    our sub dualvar(\a,\b) is export(:SUPPORTED) {
        given a.Numeric {
            when Int     { IntStr.new($_, b)     }
            when Num     { NumStr.new($_, b)     }
            when Rat     { RatStr.new($_, b)     }
            when Complex { ComplexStr.new($_, b) }
            default { die "Numeric didn't die, yet not Int,Num,Rat or Complex" }
        }
    }
    our sub isdual(\a) is export(:SUPPORTED) {
        so a ~~ any(IntStr,NumStr,RatStr,ComplexStr)
    }
    our sub readonly(\a) is export(:SUPPORTED) {
        use nqp;
        nqp::p6bool(nqp::not_i(nqp::iscont(a)))
    }
    our sub refaddr(\a) is export(:SUPPORTED) {
        use nqp;
        nqp::where(a)
    }
    our sub reftype(\a) is export(:SUPPORTED) {
        a ~~ Positional
          ?? 'ARRAY'
          !! a ~~ Associative
            ?? 'HASH'
            !! Nil
    }
    our sub isvstring(\a) is export(:SUPPORTED) { a ~~ Version }
    our sub looks_like_number(\a) is export(:SUPPORTED) {
        try { a.Numeric } !=== Nil
    }

    # the following functions are not functional on Perl 6
    my sub die-reference($what) is hidden-from-backtrace {
        die qq:to/TEXT/;
        '$what' is not supported on Rakudo Perl 6, because Rakudo Perl 6 does not
        do any refcounting or have the concept of a reference.
        TEXT
    }
    our sub weaken(|)   is export(:UNSUPPORTED) { die-reference('weaken')   }
    our sub isweak(|)   is export(:UNSUPPORTED) { die-reference('isweak')   }
    our sub unweaken(|) is export(:UNSUPPORTED) { die-reference('unweaken') }

    our sub openhandle(|) is export(:UNSUPPORTED) {
        die qq:to/TEXT/;
        'openhandle' is not supported on Rakudo Perl 6, because Rakudo Perl 6
        does not have the concept op typeglobs.
        TEXT
    }
    our sub set_prototype(|) is export(:UNSUPPORTED) {
        die qq:to/TEXT/;
        'set_prototype' is not supported on Rakudo Perl 6, because Rakudo Perl 6
        does not have the concept of prototypes.
        TEXT
    }
    our sub tainted(|) is export(:UNSUPPORTED) {
        die qq:to/TEXT/;
        'tainted' is not supported on Rakudo Perl 6, because Rakudo Perl 6
        does not have the concept of taint built in.
        TEXT
    }
}

sub EXPORT(*@args) {
    return Map.new unless @args;

    # check if we're trying to import stuff we don't support
    if EXPORT::UNSUPPORTED::{ @args.map: '&' ~ * }:v -> @absentees {
        my @messages;
        for @absentees {
            CATCH { when X::AdHoc { @messages.push(.message); .resume } }
            $_()
        }
        die @messages.join
    }

    my $imports := Map.new( |(EXPORT::SUPPORTED::{ @args.map: '&' ~ * }:p) );
    if $imports != @args {
        die "Scalar::Util doesn't know how to export: "
          ~ @args.grep( { !$imports{$_} } ).join(', ')
    }
    $imports
}

=begin pod

=head1 NAME

Scalar::Util - Port of Perl 5's Scalar::Util 1.49

=head1 SYNOPSIS

    use Scalar::Util <blessed dualvar isdual readonly refaddr reftype
                      isvstring looks_like_number>

=head1 DESCRIPTION

C<Scalar::Util> contains a selection of subroutines that people have expressed
would be nice to have in the perl core, but the usage would not really be high
enough to warrant the use of a keyword, and the size would be so small that 
being individual extensions would be wasteful.

By default C<Scalar::Util> does not export any subroutines.

=head2 blessed

    my $class = blessed( $object );

Returns the name of the class of the object.

=head2 refaddr

    my $addr = refaddr( $object );

Returns the internal memory address of the object as a plain integer.  Please note
that Perl 6 implementations do B<not> require the memory address of an object to
be constant: in fact, with C<MoarVM> as a back end, any longer living object
B<will> have its memory address changed over its lifetime.

=head2 reftype

    my $type = reftype( $object );

For objects performing the C<Positional> role, C<ARRAY> will be returned.  For
objects performing the C<Associative> role, C<HASH> will be returned.  Otherwise
C<Nil> will be returned.

=head2 dualvar

    my $var = dualvar( $num, $string );

Returns a scalar that has the value C<$num> when used as a number and the value
C<$string> when used as a string.

    $foo = dualvar 10, "Hello";
    $num = $foo + 2;                    # 12
    $str = $foo . " world";             # Hello world

=head2 isdual

    my $dual = isdual( $var );

If C<$var> is a scalar that has both numeric and string values, the result is
true.

    $foo = dualvar 86, "Nix";
    $dual = isdual($foo);               # True

=head2 isvstring

    my $vstring = isvstring( $var );

Returns whether C<$var> is a C<Version> object.

    $vs    = v49.46.48;
    $isver = isvstring($vs);            # True

=head2 looks_like_number

    my $isnum = looks_like_number( $var );

Returns true if C<$var> can be coerced to a number.

=head2 readonly

    my $ro = readonly( $var );

Returns true if C<$var> is readonly (aka does not have a container).

    sub foo(\value) { readonly(value) }

    $readonly = foo($bar);              # False
    $readonly = foo(0);                 # True

=head1 FUNCTIONS NOT PORTED

It did not make sense to port the following functions to Perl 6, as they pertain
to specific Pumpkin Perl 5 internals.

  weaken isweak unweaken openhandle set_prototype tainted

Attempting to import these functions will result in a compilation error with
hopefully targeted feedback.  Attempt to call these functions using the fully
qualified name (e.g. C<Scalar::Util::weaken($a)>) will result in a run time
error with the same feedback.

=head1 SEE ALSO

L<List::Util>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Scalar-Util . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5
version originally developed by Graham Barr, subsequently maintained by Matthijs
van Duin, cPanel and Paul Evans.

=end pod
