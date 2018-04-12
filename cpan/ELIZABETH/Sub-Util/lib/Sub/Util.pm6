use v6.c;

class Sub::Util:ver<0.0.2> {

    our sub subname(&code) is export(:SUPPORTED) {
        if &code.name -> $name {
            &code.package.^name ~ '::' ~ $name
        }
        else {
            '__ANON__'
        }
    }

    our proto sub set_subname(|) is export(:SUPPORTED) {*}
    # handle name, { ... } case
    multi sub set_subname($name, &callable) { set-subname($name,     &callable)   }
    # handle "foo" => { ... } case
    multi sub set_subname(Pair:D $pair)     { set-subname($pair.key, $pair.value) }
    # handle foo => { ... } case
    multi sub set_subname(*%_ where * == 1) { set-subname(|%_.kv) }

    # the workhorse
    my sub set-subname($name, &callable) {
        &callable.set_name(
          $name.contains('::')
            ?? $name
            !! CALLER::CALLER::<::?PACKAGE>.^name ~ '::' ~ $name
        );
        &callable
    }

    # the following functions are not functional on Perl 6
    my sub die-prototype($what) is hidden-from-backtrace {
        die qq:to/TEXT/;
        '$what' is not supported on Rakudo Perl 6, because Rakudo Perl 6
        does not have the concept of prototypes.
        TEXT
    }
    our sub prototype(|) is export(:UNSUPPORTED) {
        die-prototype('prototype')
    }
    our sub set_prototype(|) is export(:UNSUPPORTED) {
        die-prototype('set_prototype')
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
        die "Sub::Util doesn't know how to export: "
          ~ @args.grep( { !$imports{$_} } ).join(', ')
    }
    $imports
}

=begin pod

=head1 NAME

Sub::Util - Port of Perl 5's Sub::Util 1.49

=head1 SYNOPSIS

    use Sub::Util <subname set_subname>

=head1 DESCRIPTION

C<Sub::Util> contains a selection of subroutines that people have expressed
would be nice to have in the perl core, but the usage would not really be high
enough to warrant the use of a keyword, and the size would be so small that 
being individual extensions would be wasteful.

By default C<Sub::Util> does not export any subroutines.

=head2 subname

    my $name = subname( $callable );

Returns the name of the given Callable, if it has one. Normal named subs will
give a fully-qualified name consisting of the package and the localname
separated by C<::>.  Anonymous Callables will give C<__ANON__> as the localname.
If a name has been set using C<set_subname>, this name will be returned instead.

I<Users of Sub::Name beware>: This function is B<not> the same as
C<Sub::Name::subname>; it returns the existing name of the sub rather than
changing it. To set or change a name, see instead C<set_subname>.

=head2 set_subname

    my $callable = set_subname $name, $callable;

Sets the name of the function given by the Callable. Returns the Callable itself.
If the C<$name> is unqualified, the package of the caller is used to qualify it.

This is useful for applying names to anonymous Callables so that stack
traces and similar situations, to give a useful name rather than having the
default. Note that this name is only used for this situation; the C<set_subname>
will not install it into the symbol table; you will have to do that yourself if
required.

However, since the name is not used by perl except as the return value of
C<caller>, for stack traces or similar, there is no actual requirement that
the name be syntactically valid as a perl function name. This could be used to
attach extra information that could be useful in debugging stack traces.

This function was copied from C<Sub::Name::subname> and renamed to the naming
convention of this module.

=head1 FUNCTIONS NOT PORTED

It did not make sense to port the following functions to Perl 6, as they pertain
to specific Pumpkin Perl 5 internals.

  prototype set_prototype

Attempting to import these functions will result in a compilation error with
hopefully targeted feedback.  Attempt to call these functions using the fully
qualified name (e.g. C<Sub::Util::set_prototype($a)>) will result in a run time
error with the same feedback.

=head1 SEE ALSO

L<Sub::Name>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sub-Util . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5
version originally developed by Paul Evans.

=end pod
