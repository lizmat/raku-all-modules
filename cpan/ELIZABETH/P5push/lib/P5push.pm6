use v6.c;

unit module P5push:ver<0.0.4>:auth<cpan:ELIZABETH>;

proto sub push(|) is export {*}
multi sub push(@array,*@values --> Int:D) {
    @array.append(@values).elems
}

proto sub pop(|) is export {*}
multi sub pop() {
    mainline()                # heuristic for top level calling
      ?? pop(@*ARGS)            # top level, use @ARGV equivalent
      !! pop(CALLERS::<@_>)     # pop from the caller's @_
}
multi sub pop(@array) {
    @array.elems ?? @array.pop !! Nil
}

sub mainline(--> Bool:D) {  # heuristic for top level calling
    # Before Rakudo commit 0d216befba336b1cd7a0b42, thunky things such as
    # an onlystar proto would be "seen" by callframe().  Subsequent calls
    # to the proto would be skipped if the call could be performed through
    # the multi-dispatch cache, causing the info to be returned of one
    # level deeper.
    callframe(2).my<!UNIT_MARKER>:exists  # post commit 0d216befba336b1cd7a0b42
      || (callframe(3).my<!UNIT_MARKER>:exists) || !callframe(3).my
}

=begin pod

=head1 NAME

P5push - Implement Perl 5's push() / pop() built-ins

=head1 SYNOPSIS

  use P5push;

  my @a = 1,2,3;
  say push @a, 42;  # 4

  say pop;  # pop from @*ARGS, if any

  sub a { dd @_; dd pop; dd @_ }; a 1,2,3;
  [1, 2, 3]
  3
  [1, 2]

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<push> and C<pop> functions
of Perl 5 as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    push ARRAY,LIST
    push EXPR,LIST
            Treats ARRAY as a stack by appending the values of LIST to the end
            of ARRAY. The length of ARRAY increases by the length of LIST. Has
            the same effect as

                for $value (LIST) {
                    $ARRAY[++$#ARRAY] = $value;
                }

            but is more efficient. Returns the number of elements in the array
            following the completed "push".

            Starting with Perl 5.14, "push" can take a scalar EXPR, which must
            hold a reference to an unblessed array. The argument will be
            dereferenced automatically. This aspect of "push" is considered
            highly experimental. The exact behaviour may change in a future
            version of Perl.

            To avoid confusing would-be users of your code who are running
            earlier versions of Perl with mysterious syntax errors, put this
            sort of thing at the top of your file to signal that your code
            will work onlyon Perls of a recent vintage:

                use 5.014;  # so push/pop/etc work on scalars (experimental)

    pop ARRAY
    pop EXPR
    pop     Pops and returns the last value of the array, shortening the array
            by one element.

            Returns the undefined value if the array is empty, although this
            may also happen at other times. If ARRAY is omitted, pops the
            @ARGV array in the main program, but the @_ array in subroutines,
            just like "shift".

            Starting with Perl 5.14, "pop" can take a scalar EXPR, which must
            hold a reference to an unblessed array. The argument will be
            dereferenced automatically. This aspect of "pop" is considered
            highly experimental. The exact behaviour may change in a future
            version of Perl.

            To avoid confusing would-be users of your code who are running
            earlier versions of Perl with mysterious syntax errors, put this
            sort of thing at the top of your file to signal that your code
            will work [4monly[m on Perls of a recent vintage:

                use 5.014;  # so push/pop/etc work on scalars (experimental)

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5push . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
