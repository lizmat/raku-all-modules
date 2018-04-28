use v6.c;

unit module P5push:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub push(|) is export {*}
multi sub push(@array,*@values --> Int:D) {
    @array.push(@values).elems
}

proto sub pop(|) is export {*}
multi sub pop() {
    callframe(2).my<!UNIT_MARKER>:exists  # heuristic for top level calling
      ?? pop(@*ARGS)                        # top level, use @ARGV equivalent
      !! pop(CALLERS::<@_>)                 # pop from the caller's @_
}
multi sub pop(@array) {
    @array.elems ?? @array.pop !! Nil
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

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5push . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
