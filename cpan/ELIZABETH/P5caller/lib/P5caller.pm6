use v6.c;

unit module P5caller:ver<0.0.6>:auth<cpan:ELIZABETH>;

proto sub caller(|) is export {*}
multi sub caller(Scalar:U) { backtrace(1, True)     }
multi sub caller(:$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    backtrace(1, True)
}
multi sub caller() { backtrace(1) }
multi sub caller(Scalar:U, Int() $down) { backtrace($down, True) }
multi sub caller(Int() $down, :$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    backtrace($down, True)
}
multi sub caller(Int() $down) { backtrace($down) }

my sub backtrace($down is copy, $scalar?) {
    $down += 3;  # offset heuristic
    my $backtrace := Backtrace.new;
    my $index = 0;
    $index = $backtrace.next-interesting-index($index, :named, :noproto)
      for ^$down;

    with Backtrace.new.AT-POS($index) {
        my $package = .subname eq '<unit>' ?? 'GLOBAL' !! .code.package.^name;
        $scalar
          ?? $package
          !! ($package, .file, .line, .subname, .code)
    }
}

=begin pod

=head1 NAME

P5caller - Implement Perl 5's caller() built-in

=head1 SYNOPSIS

  use P5caller;

  sub foo { bar }
  sub bar { say caller[3] }        # foo

  sub baz { say caller(:scalar) }  # GLOBAL
  my $package = caller

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<caller> function of Perl 5
as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    caller EXPR
    caller  Returns the context of the current pure perl subroutine call. In
            scalar context, returns the caller's package name if there is a
            caller (that is, if we're in a subroutine or "eval" or "require")
            and the undefined value otherwise. caller never returns XS subs
            and they are skipped. The next pure perl sub will appear instead
            of the XS sub in caller's return values. In list context, caller
            returns

                # 0         1          2
                ($package, $filename, $line) = caller;

            With EXPR, it returns some extra information that the debugger
            uses to print a stack trace. The value of EXPR indicates how many
            call frames to go back before the current one.

                #  0         1          2      3            4
                ($package, $filename, $line, $subroutine, $hasargs,

                #  5          6          7            8       9         10
                $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash)
                 = caller($i);

            Here, $subroutine is the function that the caller called (rather
            than the function containing the caller). Note that $subroutine
            may be "(eval)" if the frame is not a subroutine call, but an
            "eval". In such a case additional elements $evaltext and
            $is_require are set: $is_require is true if the frame is created
            by a "require" or "use" statement, $evaltext contains the text of
            the "eval EXPR" statement. In particular, for an "eval BLOCK"
            statement, $subroutine is "(eval)", but $evaltext is undefined.
            (Note also that each "use" statement creates a "require" frame
            inside an "eval EXPR" frame.) $subroutine may also be "(unknown)"
            if this particular subroutine happens to have been deleted from
            the symbol table. $hasargs is true if a new instance of @_ was set
            up for the frame. $hints and $bitmask contain pragmatic hints that
            the caller was compiled with. $hints corresponds to $^H, and
            $bitmask corresponds to "${^WARNING_BITS}". The $hints and
            $bitmask values are subject to change between versions of Perl,
            and are not meant for external use.

            $hinthash is a reference to a hash containing the value of "%^H"
            when the caller was compiled, or "undef" if "%^H" was empty. Do
            not modify the values of this hash, as they are the actual values
            stored in the optree.

            Furthermore, when called from within the DB package in list
            context, and with an argument, caller returns more detailed
            information: it sets the list variable @DB::args to be the
            arguments with which the subroutine was invoked.

            Be aware that the optimizer might have optimized call frames away
            before "caller" had a chance to get the information. That means
            that caller(N) might not return information about the call frame
            you expect it to, for "N > 1". In particular, @DB::args might have
            information from the previous time "caller" was called.

            Be aware that setting @DB::args is best effort, intended for
            debugging or generating backtraces, and should not be relied upon.
            In particular, as @_ contains aliases to the caller's arguments,
            Perl does not take a copy of @_, so @DB::args will contain
            modifications the subroutine makes to @_ or its contents, not the
            original values at call time. @DB::args, like @_, does not hold
            explicit references to its elements, so under certain cases its
            elements may have become freed and reallocated for other variables
            or temporary values. Finally, a side effect of the current
            implementation is that the effects of "shift @_" can normally be
            undone (but not "pop @_" or other splicing, and not if a reference
            to @_ has been taken, and subject to the caveat about reallocated
            elements), so @DB::args is actually a hybrid of the current state
            and initial state of @_. Buyer beware.

=head1 PORTING CAVEATS

In Perl 5, C<caller> can return an 11 element list.  In the Perl 6
implementation only the first 4 elements are the same as in Perl 5:
package, filename, line, subname.  The fifth element is actually the
C<Sub> or C<Method> object and as such provides further introspection
possibilities not found in Perl 5.

As there is no such thing as C<scalar> or C<list> context in Perl 6, one
must specify a C<:scalar> named parameter to emulate the scalar context
return value.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5caller . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
